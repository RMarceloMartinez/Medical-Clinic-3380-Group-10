using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;

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

    public async Task<AppointmentResponse?> GetByAsyncID(
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
        return new AppointmentResponse
        {
            AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
            OfficeID = reader.GetInt32(reader.GetOrdinal("OfficeID")),
            DoctorID = reader.GetInt32(reader.GetOrdinal("DoctorID")),
            PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
            ReferralID = reader.IsDBNull(reader.GetOrdinal("ReferralID"))
                ?null
                :reader.GetInt32(reader.GetOrdinal("ReferralID")),
            AppointmentDateTime  = reader.GetDateTime(reader.GetOrdinal("AppointmentDateTime ")),
            AppointStatus  = reader.GetString(reader.GetOrdinal("AppointStatus")),
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