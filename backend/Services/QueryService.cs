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
}
