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
                @Date_Time, @TotalCost, @Channel, 'Scheduled',
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
        command.Parameters.Add("@Date_Time", SqlDbType.DateTime2).Value = request.AppointmentDateTime.Value;
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

}