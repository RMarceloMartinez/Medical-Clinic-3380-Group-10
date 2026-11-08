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
        CancellationToken cancellationToken)
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
                SELECT a.AppointStatus, a.CancellationFee,
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

            if (reader.GetString(0) == "Cancelled")
            {
                decimal fee = reader.IsDBNull(1) ? 0 : reader.GetDecimal(1);
                decimal paid = reader.GetDecimal(2);
                decimal remaining = Math.Max(0, fee - paid);
                decimal amount = request.Details.Sum(d => d.AmountApplied);

                if (fee == 0 || amount > remaining)
                    throw new ArgumentException(
                        $"This visit was cancelled; only ${remaining:0.00} of the cancellation fee remains to be paid.");
            }
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
}