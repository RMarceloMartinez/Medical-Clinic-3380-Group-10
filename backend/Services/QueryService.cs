using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

public class QueryService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public QueryService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<List<PatientSearchRow>> SearchPatientsAsync(string? name, DateOnly? dateOfBirth,
                                                CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                              EXEC dbo.usp_SearchPatients
                              @Name = @Name, @DateOfBirth = @DateOfBirth;
                              """;

        command.Parameters.Add("@Name", SqlDbType.VarChar, 50).Value = (object?)name ?? DBNull.Value;
        command.Parameters.Add("@DateOfBirth", SqlDbType.Date).Value = (object?)dateOfBirth ?? DBNull.Value;

        var items = new List<PatientSearchRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new PatientSearchRow
            {
                PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
                PatientName = reader.GetString(reader.GetOrdinal("PatientName")),
                DateOfBirth = DateOnly.FromDateTime(reader.GetDateTime(reader.GetOrdinal("DateOfBirth"))),
                Phone = reader.GetString(reader.GetOrdinal("Phone"))
            });
        }

        return items;
    }
    public async Task<PatientBalanceRow?> GetPatientBalanceAsync(int patientId,
                                                CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                              EXEC dbo.usp_PatientBalance @PatientID = @PatientID;
                              """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))   // one row expected; none = null
        {
            return null;
        }

        return new PatientBalanceRow
        {
            Billed = reader.GetDecimal(reader.GetOrdinal("Billed")),
            Paid = reader.GetDecimal(reader.GetOrdinal("Paid")),
            Balance = reader.GetDecimal(reader.GetOrdinal("Balance"))
        };
    }

    public async Task<List<DoctorWeekAppointmentRow>> GetDoctorWeekAppointmentsAsync(int doctorId, DateOnly weekStart,
                                                CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                              EXEC dbo.usp_DoctorWeekAppointments
                              @DoctorID = @DoctorID, @WeekStart = @WeekStart;
                              """;

        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;
        command.Parameters.Add("@WeekStart", SqlDbType.Date).Value = weekStart;

        var items = new List<DoctorWeekAppointmentRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new DoctorWeekAppointmentRow
            {
                Date_Time = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
                PatientName = reader.GetString(reader.GetOrdinal("PatientName")),
                Office = reader.GetString(reader.GetOrdinal("Office")),
                AppointStatus = reader.GetString(reader.GetOrdinal("AppointStatus"))
            });
        }

        return items;
    }
}
