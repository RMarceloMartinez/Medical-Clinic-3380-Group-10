using ClinicApi.Data;
using ClinicApi.Models;

namespace ClinicApi.Services;

public class LookupService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public LookupService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }
    public Task<List<LookupItem>> GetDoctorsAsync(CancellationToken cancellationToken = default)
    {
        return QueryAsync("""
            SELECT d.DoctorID AS Id,
                   m.FirstName + ' ' + m.LastName + ' (' + d.Specialty + ')' AS Name
            FROM dbo.Doctor AS d
            JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
            WHERE d.DeletionFlag = 0
              AND m.DeletionFlag = 0
            ORDER BY m.LastName, m.FirstName;
            """, cancellationToken);
    }

    public Task<List<LookupItem>> GetPrimaryDoctorsAsync(CancellationToken cancellationToken = default)
    {
        return QueryAsync("""
            SELECT d.DoctorID AS Id,
                   m.FirstName + ' ' + m.LastName + ' (' + d.Specialty + ')' AS Name
            FROM dbo.Doctor AS d
            JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
            WHERE d.Specialty IN ('Family Medicine', 'Internal Medicine', 'Pediatrics')
              AND d.DeletionFlag = 0
              AND m.DeletionFlag = 0
            ORDER BY m.LastName, m.FirstName;
            """, cancellationToken);
    }
    public Task<List<LookupItem>> GetPatientsAsync(CancellationToken cancellationToken = default)
    {
        return QueryAsync("""
            SELECT p.PatientID AS Id,
                   m.FirstName + ' ' + m.LastName
                   + ' (born ' + CONVERT(VARCHAR(10), m.DateOfBirth, 23) + ')' AS Name
            FROM dbo.Patient AS p
            JOIN dbo.Member AS m ON m.MemberID = p.PatientID
            WHERE p.DeletionFlag = 0
              AND m.DeletionFlag = 0
            ORDER BY m.LastName, m.FirstName;
            """, cancellationToken);
    }

    public Task<List<LookupItem>> GetOfficesAsync(CancellationToken cancellationToken = default)
    {
        return QueryAsync("""
            SELECT OfficeID AS Id,
                   StreetAddress + ', ' + City AS Name
            FROM dbo.Office
            WHERE DeletionFlag = 0
            ORDER BY City, StreetAddress;
            """, cancellationToken);
    }
    private async Task<List<LookupItem>> QueryAsync(string sql, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText = sql;

        var items = new List<LookupItem>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new LookupItem
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Name = reader.GetString(reader.GetOrdinal("Name"))
            });
        }

        return items;
    }
}