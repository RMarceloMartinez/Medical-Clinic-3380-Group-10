using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;

namespace ClinicApi.Services;

public class PaymentService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public PaymentService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<PaymentResponse?> GetByIdAsync(
        int paymentId,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
            SELECT
                p.PaymentID,
                p.AppointmentID,
                p.InstallmentNumber,
                p.PaymentDate,
                p.PayStatus,
                pd.MethodID,
                pm.MethodName,
                pd.AmountApplied
            FROM dbo.Payment AS p
            LEFT JOIN dbo.PaymentDetail AS pd
                ON pd.PaymentID = p.PaymentID
                AND pd.DeletionFlag = 0
            LEFT JOIN dbo.PaymentMethod AS pm
                ON pm.MethodID = pd.MethodID
            WHERE p.PaymentID = @PaymentID
              AND p.DeletionFlag = 0
            ORDER BY pd.MethodID;
            """;

        command.Parameters.Add("@PaymentID", SqlDbType.Int)
            .Value = paymentId;

        using var reader =
            await command.ExecuteReaderAsync(cancellationToken);

        PaymentResponse? payment = null;

        while (await reader.ReadAsync(cancellationToken))
        {
            payment ??= new PaymentResponse
            {
                PaymentID = reader.GetInt32(0),
                AppointmentID = reader.GetInt32(1),
                InstallmentNumber = reader.GetInt32(2),
                PaymentDate = DateOnly.FromDateTime(
                    reader.GetDateTime(3)),
                PayStatus = reader.GetString(4)
            };

            if (!reader.IsDBNull(5))
            {
                payment.Details.Add(new PaymentDetailResponse
                {
                    MethodID = reader.GetInt32(5),
                    MethodName = reader.GetString(6),
                    AmountApplied = reader.GetDecimal(7)
                });
            }
        }

        return payment;
    }
    public async Task<int> CreateAsync(
        CreatePaymentRequest request,
        CancellationToken cancellationToken,
        int? patientId = null)
    {
        if (request.PaymentDate is null)
            throw new ArgumentException("Payment date is required.");

        if (request.Details is null || request.Details.Count == 0)
            throw new ArgumentException("Payment details are required.");

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var transaction = connection.BeginTransaction();

        // Coordinate payments for the same appointment
        using (var appointmentCommand = connection.CreateCommand())
        {
            appointmentCommand.Transaction = transaction;
            appointmentCommand.CommandText = """
                SELECT a.AppointStatus, a.CancellationFee, a.PatientID, a.TotalCost,
                    ISNULL((
                        SELECT SUM(pd.AmountApplied)
                        FROM dbo.Payment AS p
                        JOIN dbo.PaymentDetail AS pd
                            ON pd.PaymentID = p.PaymentID
                        WHERE p.AppointmentID = a.AppointmentID
                          AND p.PayStatus = 'Completed'
                          AND p.DeletionFlag = 0
                          AND pd.DeletionFlag = 0
                    ), 0) AS AlreadyPaid
                FROM dbo.Appointment AS a WITH (UPDLOCK, HOLDLOCK)
                WHERE a.AppointmentID = @AppointmentID
                  AND a.DeletionFlag = 0;
                """;

            // Status and cancellation fee
            // Total completed payments for this visit
            appointmentCommand.Parameters
                .Add("@AppointmentID", SqlDbType.Int)
                .Value = request.AppointmentID;

            using var reader = await appointmentCommand
                .ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
                throw new KeyNotFoundException(
                    "Appointment was not found.");


            if (patientId.HasValue)
            {
                if (reader.GetInt32(2) != patientId.Value)
                    throw new KeyNotFoundException("Appointment was not found.");

                string status = reader.GetString(0);
                decimal charge = status == "Completed"
                    ? reader.GetDecimal(3)
                    : status == "Cancelled" && !reader.IsDBNull(1)
                        ? reader.GetDecimal(1) : 0;
                decimal remaining = Math.Max(0, charge - reader.GetDecimal(4));
                decimal amount = request.Details.Sum(d => d.AmountApplied);

                if (remaining == 0)
                    throw new ArgumentException("This visit has no balance due.");

                if (amount <= 0 || amount > remaining)
                    throw new ArgumentException(
                        $"Enter an amount up to ${remaining:0.00}.");
            }

            if (reader.GetString(0) == "Cancelled")
            {
                decimal fee = reader.IsDBNull(1) ? 0 : reader.GetDecimal(1);
                decimal paid = reader.GetDecimal(4);
                decimal remaining = Math.Max(0, fee - paid);
                decimal amount = request.Details.Sum(d => d.AmountApplied);

                // No fee: the insert goes on and trigger 50007 refuses it with its own message
                if (fee > 0 && remaining == 0)
                    throw new ArgumentException(
                        $"The ${fee:0.00} cancellation fee for this visit is already paid.");

                if (fee > 0 && amount > remaining)
                    throw new ArgumentException(
                        $"This visit was cancelled; only ${remaining:0.00} of the cancellation fee remains to be paid.");
            }
        }



        if (patientId.HasValue)
        {
            // The appointment lock remains held until this transaction commits.
            using var next = connection.CreateCommand();
            next.Transaction = transaction;
            next.CommandText = """
                SELECT ISNULL(MAX(InstallmentNumber), 0) + 1
                FROM dbo.Payment
                WHERE AppointmentID = @AppointmentID;
                """;
            next.Parameters.Add("@AppointmentID", SqlDbType.Int)
                .Value = request.AppointmentID;
            request.InstallmentNumber =
                Convert.ToInt32(await next.ExecuteScalarAsync(cancellationToken));
        }

        int paymentId;

        using (var paymentCommand = connection.CreateCommand())
        {
            paymentCommand.Transaction = transaction;
            paymentCommand.CommandText = """
                DECLARE @NewPayment TABLE (PaymentID INT);

                INSERT INTO dbo.Payment
                    (AppointmentID, InstallmentNumber,
                     PaymentDate, PayStatus, DeletionFlag)
                OUTPUT INSERTED.PaymentID
                    INTO @NewPayment (PaymentID)
                VALUES
                    (@AppointmentID, @InstallmentNumber,
                     @PaymentDate, @PayStatus, 0);

                SELECT PaymentID FROM @NewPayment;
                """;

            paymentCommand.Parameters
                .Add("@AppointmentID", SqlDbType.Int)
                .Value = request.AppointmentID;

            paymentCommand.Parameters
                .Add("@InstallmentNumber", SqlDbType.Int)
                .Value = request.InstallmentNumber;

            paymentCommand.Parameters
                .Add("@PaymentDate", SqlDbType.Date)
                .Value = request.PaymentDate.Value
                    .ToDateTime(TimeOnly.MinValue);

            paymentCommand.Parameters
                .Add("@PayStatus", SqlDbType.VarChar, 9)
                .Value = request.PayStatus;

            var result = await paymentCommand
                .ExecuteScalarAsync(cancellationToken);

            if (result is not int id)
                throw new InvalidOperationException(
                    "Could not retrieve the new payment ID.");

            paymentId = id;
        }

        foreach (var detail in request.Details)
        {
            using var detailCommand = connection.CreateCommand();

            detailCommand.Transaction = transaction;
            detailCommand.CommandText = """
                INSERT INTO dbo.PaymentDetail
                    (PaymentID, MethodID, AmountApplied, DeletionFlag)
                VALUES
                    (@PaymentID, @MethodID, @AmountApplied, 0);
                """;

            detailCommand.Parameters
                .Add("@PaymentID", SqlDbType.Int)
                .Value = paymentId;

            detailCommand.Parameters
                .Add("@MethodID", SqlDbType.Int)
                .Value = detail.MethodID;

            var amountParameter = detailCommand.Parameters
                .Add("@AmountApplied", SqlDbType.Decimal);

            amountParameter.Precision = 10;
            amountParameter.Scale = 2;
            amountParameter.Value = detail.AmountApplied;

            await detailCommand.ExecuteNonQueryAsync(
                cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);

        return paymentId;
    }

    public async Task<List<object>> GetPatientChargesAsync(
        int patientId, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT a.AppointmentID, a.Date_Time, a.AppointStatus,
                CASE WHEN a.AppointStatus = 'Cancelled'
                    THEN ISNULL(a.CancellationFee, 0)
                    ELSE a.TotalCost END AS Charge,
                ISNULL((
                    SELECT SUM(pd.AmountApplied)
                    FROM dbo.Payment p
                    JOIN dbo.PaymentDetail pd ON pd.PaymentID = p.PaymentID
                    WHERE p.AppointmentID = a.AppointmentID
                      AND p.PayStatus = 'Completed'
                      AND p.DeletionFlag = 0
                      AND pd.DeletionFlag = 0
                ), 0) AS Paid,
                'Dr. ' + dm.FirstName + ' ' + dm.LastName AS DoctorName
            FROM dbo.Appointment a
            JOIN dbo.Member dm ON dm.MemberID = a.DoctorID
            WHERE a.PatientID = @PatientID
              AND a.DeletionFlag = 0
              AND (a.AppointStatus = 'Completed'
                OR (a.AppointStatus = 'Cancelled'
                    AND ISNULL(a.CancellationFee, 0) > 0))
            ORDER BY a.Date_Time DESC, a.AppointmentID DESC;
            """;
        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var rows = new List<object>();
        while (await reader.ReadAsync(cancellationToken))
        {
            decimal charge = reader.GetDecimal(3);
            decimal paid = reader.GetDecimal(4);
            rows.Add(new
            {
                appointmentID = reader.GetInt32(0),
                appointmentDateTime = reader.GetDateTime(1),
                status = reader.GetString(2),
                doctorName = reader.GetString(5),
                charge,
                paid,
                remaining = Math.Max(0, charge - paid)
            });
        }
        return rows;
    }

    public async Task<List<object>> GetPatientPaymentHistoryAsync(
        int patientId, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT p.PaymentID, p.AppointmentID, p.PaymentDate,
                   p.PayStatus, a.Date_Time,
                   pm.MethodName, pd.AmountApplied,
                   'Dr. ' + dm.FirstName + ' ' + dm.LastName AS DoctorName
            FROM dbo.Payment p
            JOIN dbo.Appointment a ON a.AppointmentID = p.AppointmentID
            JOIN dbo.Member dm ON dm.MemberID = a.DoctorID
            LEFT JOIN dbo.PaymentDetail pd
                ON pd.PaymentID = p.PaymentID AND pd.DeletionFlag = 0
            LEFT JOIN dbo.PaymentMethod pm ON pm.MethodID = pd.MethodID
            WHERE a.PatientID = @PatientID
              AND a.DeletionFlag = 0
              AND p.DeletionFlag = 0
            ORDER BY p.PaymentDate DESC, p.PaymentID DESC, pd.MethodID;
            """;
        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var rows = new List<object>();
        while (await reader.ReadAsync(cancellationToken))
        {
            rows.Add(new
            {
                paymentID = reader.GetInt32(0),
                appointmentID = reader.GetInt32(1),
                paymentDate = reader.GetDateTime(2).ToString("yyyy-MM-dd"),
                status = reader.GetString(3),
                appointmentDateTime = reader.GetDateTime(4),
                method = reader.IsDBNull(5) ? "Not recorded" : reader.GetString(5),
                amount = reader.IsDBNull(6) ? 0m : reader.GetDecimal(6),
                doctorName = reader.GetString(7)
            });
        }
        return rows;
    }

    public async Task<List<object>> GetPaymentMethodsAsync(
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        using var command = connection.CreateCommand();
        command.CommandText =
            // Online payments take a card only (2 = Credit Card, 3 = Debit Card)
            "SELECT MethodID, MethodName FROM dbo.PaymentMethod WHERE MethodID IN (2, 3) AND DeletionFlag = 0 ORDER BY MethodID;";
        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var rows = new List<object>();
        while (await reader.ReadAsync(cancellationToken))
            rows.Add(new
            {
                methodID = reader.GetInt32(0),
                methodName = reader.GetString(1)
            });
        return rows;
    }

}
