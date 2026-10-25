using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

public class AppointmentService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public AppointmentService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<int> CreateAsync(
        CreateAppointmentRequest request,
        CancellationToken cancellationToken = default
    )
    {
        if (request.AppointmentDateTime is null)
        {
            throw new ArgumentException("Appointment date and time is required.");
        }  

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
        DECLARE @NewAppointment TABLE (AppointmentID INT);
        INSERT INTO dbo.Appointment(
                                    OfficeID, DoctorID, PatientID, ReferralID,
                                    Date_Time, TotalCost, Channel,
                                    AppointStatus, CancelReason, CancelledBy, DeletionFlag
                                    )
        OUTPUT INSERTED.AppointmentID
        INTO @NewAppointment(AppointmentID)
        Values(
                @OfficeID, @DoctorID, @PatientID, @ReferralID,
                @AppointmentDateTime, @TotalCost, @Channel, 'Scheduled',
                NULL, NULL, 0
                );
        SELECT AppointmentID FROM @NewAppointment
        """;
        
        command.Parameters.Add("@OfficeID", SqlDbType.Int).Value = request.OfficeID;
        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = request.DoctorID;
        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = request.PatientID;
        command.Parameters.Add("@ReferralID", SqlDbType.Int).Value = request.ReferralID.HasValue
                                                                    ? request.ReferralID
                                                                    : DBNull.Value;
        command.Parameters.Add("@AppointmentDateTime", SqlDbType.DateTime2).Value = request.AppointmentDateTime.Value;
        var costParameter = command.Parameters.Add("@TotalCost", SqlDbType.Decimal);
        costParameter.Precision = 10;
        costParameter.Scale = 2;
        costParameter.Value = request.TotalCost;
        command.Parameters.Add("@Channel", SqlDbType.VarChar, 10).Value = request.Channel;

        var result = await command.ExecuteScalarAsync(cancellationToken);

        if(result is not int id)
        {
            throw new InvalidOperationException("Could not retrieve new Appointment ID.");
        }
        return id;
    }

    public async Task<AppointmentResponse?> GetByIdAsync(
        int appointmentID,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                            SELECT *
                            FROM dbo.Appointment
                            WHERE AppointmentID = @AppointmentID
                            AND DeletionFlag = 0;
                            """;

        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentID;

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if(!await reader.ReadAsync(cancellationToken)){
            return null;
        }
        return Map(reader);
    }

    public async Task<List<AppointmentResponse>>ListAsync(
        int? doctorId,
        int? patientId,
        int? officeId,
        DateTime? from,
        DateTime? to,
        string? status,
        CancellationToken cancellationToken = default
    )
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText =   """
                                SELECT *
                                FROM dbo.Appointment
                                WHERE DeletionFlag = 0
                                AND (@DoctorID  IS NULL OR DoctorID  = @DoctorID)
                                AND (@PatientID IS NULL OR PatientID = @PatientID)
                                AND (@OfficeID  IS NULL OR OfficeID = @OfficeID)
                                AND (@Status    IS NULL OR AppointStatus = @Status)
                                AND (@From      IS NULL OR Date_Time >= @From)
                                AND (@To        IS NULL OR Date_Time <  DATEADD(DAY, 1, @To))
                                ORDER BY Date_Time;
                                """;
        
        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = (object?)doctorId ?? DBNull.Value;
        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = (object?)patientId ?? DBNull.Value;
        command.Parameters.Add("@OfficeID", SqlDbType.Int).Value  = (object?)officeId  ?? DBNull.Value;
        command.Parameters.Add("@Status", SqlDbType.VarChar, 9).Value = (object?)status ?? DBNull.Value;
        command.Parameters.Add("@From", SqlDbType.Date).Value = (object?)from ?? DBNull.Value;
        command.Parameters.Add("@To", SqlDbType.Date).Value   = (object?)to   ?? DBNull.Value;

        var appointments = new List<AppointmentResponse>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while(await reader.ReadAsync(cancellationToken))
        {
            appointments.Add(Map(reader));
        }
        return appointments;
    }

    public async Task<bool> CancelAsync(
        int appointmentId,
        CancelAppointmentRequest request,
        CancellationToken cancellationToken = default
    )
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText =   """
                                UPDATE dbo.Appointment
                                SET AppointStatus = 'Cancelled',
                                CancelReason  = @CancelReason,
                                CancelledBy   = @CancelledBy
                                WHERE AppointmentID = @AppointmentID
                                AND DeletionFlag = 0;
                                """;

        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;
        command.Parameters.Add("@CancelReason", SqlDbType.VarChar, 200).Value = request.CancelReason;
        command.Parameters.Add("@CancelledBy", SqlDbType.VarChar, 7).Value = request.CancelledBy;

        int rowChanged = await command.ExecuteNonQueryAsync(cancellationToken);

        return rowChanged > 0;
    }

    public async Task<bool> CompleteAsync(
        int appointmentId,
        CancellationToken cancellationToken
    )
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText =   """
                                UPDATE dbo.Appointment
                                SET AppointStatus = 'Completed',
                                CancelReason  = NULL,
                                CancelledBy   = NULL
                                WHERE AppointmentID = @AppointmentID
                                AND DeletionFlag = 0;
                                """;
        
        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;

        int rowsChanged = await command.ExecuteNonQueryAsync(cancellationToken);

        return rowsChanged > 0;
    }

    private static AppointmentResponse Map(SqlDataReader reader)
    {
        return new AppointmentResponse
        {
            AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
            OfficeID = reader.GetInt32(reader.GetOrdinal("OfficeID")),
            DoctorID = reader.GetInt32(reader.GetOrdinal("DoctorID")),
            PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
            ReferralID = reader.IsDBNull(reader.GetOrdinal("ReferralID"))
                ?null
                :reader.GetInt32(reader.GetOrdinal("ReferralID")),
            AppointmentDateTime = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
            AppointStatus  = reader.GetString(  reader.GetOrdinal("AppointStatus")),
            TotalCost  = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
            Channel  = reader.GetString(reader.GetOrdinal("Channel")),
            CancelReason = reader.IsDBNull(reader.GetOrdinal("CancelReason"))
                ? null
                : reader.GetString(reader.GetOrdinal("CancelReason")),
            CancelledBy = reader.IsDBNull(reader.GetOrdinal("CancelledBy"))
                ? null
                : reader.GetString(reader.GetOrdinal("CancelledBy"))    
        };
    }

}