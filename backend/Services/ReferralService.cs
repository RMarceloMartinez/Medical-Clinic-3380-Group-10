using System.ComponentModel;
using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;

namespace ClinicApi.Services;

public class ReferralService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public ReferralService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<List<LookupItem>> GetMyPatientsAsync(int doctorId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText =   """
                                SELECT p.PatientID AS Id,
                                m.FirstName + ' ' + m.LastName
                                + ' (born ' + CONVERT(VARCHAR(10), m.DateOfBirth, 23) + ')' AS Name
                                FROM dbo.PatientDoctor AS pd
                                JOIN dbo.Patient AS p ON p.PatientID = pd.PatientID
                                JOIN dbo.Member  AS m ON m.MemberID  = p.PatientID
                                WHERE pd.DoctorID = @DoctorID
                                AND pd.RolePlayed = 'Primary'
                                AND pd.DeletionFlag = 0
                                AND p.DeletionFlag = 0
                                AND m.DeletionFlag = 0
                                ORDER BY m.LastName, m.FirstName;
                                """;
        command.Parameters.Add("@DoctorID",SqlDbType.Int).Value = doctorId;

        var items = new List<LookupItem>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while(await reader.ReadAsync(cancellationToken))
        {
            items.Add(new LookupItem
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Name = reader.GetString(reader.GetOrdinal("Name"))
            });
        }
        return items;

    }

    public async Task<List<LookupItem>> GetSpecialistsAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText =   """
                                SELECT d.DoctorID AS Id,
                                m.FirstName + ' ' + m.LastName + ' (' + d.Specialty + ')' AS Name
                                FROM dbo.Doctor AS d
                                JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
                                JOIN dbo.Specialty AS s ON s.SpecialtyName = d.Specialty
                                WHERE s.IsPrimaryCare = 0
                                AND d.DeletionFlag = 0
                                AND m.DeletionFlag = 0
                                AND s.DeletionFlag = 0
                                ORDER BY d.Specialty, m.LastName;
                                """;
        
        var items = new List<LookupItem>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while(await reader.ReadAsync(cancellationToken))
        {
            items.Add(new LookupItem
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Name = reader.GetString(reader.GetOrdinal("Name"))
            });
        }
        return items;
    }

    public async Task<List<ReferralRow>> GetSentAsync(int doctorId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText =   """
                                SELECT r.ReferralID,
                                pm.FirstName + ' ' + pm.LastName AS PatientName,
                                'Dr. ' + sm.FirstName + ' ' + sm.LastName AS SpecialistName,
                                d.Specialty, r.DateIssued, r.RefStatus
                                FROM dbo.Referral AS r
                                JOIN dbo.Member AS pm ON pm.MemberID = r.PatientID
                                JOIN dbo.Doctor AS d  ON d.DoctorID  = r.SpecialistID
                                JOIN dbo.Member AS sm ON sm.MemberID = d.DoctorID
                                WHERE r.PrimaryID = @DoctorID AND r.DeletionFlag = 0
                                ORDER BY r.DateIssued DESC, r.ReferralID DESC;
                                """;
        
        command.Parameters.Add("@DoctorID",SqlDbType.Int).Value = doctorId;

        var rows = new List<ReferralRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            rows.Add(new ReferralRow
            {
                ReferralID     = reader.GetInt32(reader.GetOrdinal("ReferralID")),
                PatientName    = reader.GetString(reader.GetOrdinal("PatientName")),
                SpecialistName = reader.GetString(reader.GetOrdinal("SpecialistName")),
                Specialty      = reader.GetString(reader.GetOrdinal("Specialty")),
                DateIssued     = reader.GetDateTime(reader.GetOrdinal("DateIssued")),
                RefStatus      = reader.GetString(reader.GetOrdinal("RefStatus"))
            });
        }
        return rows;
    }

    public async Task<int> CreateAsync(int doctorId, CreateReferralRequest request,
                                        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText =   """
                                DECLARE @NewReferral TABLE (ReferralID INT);
                                INSERT INTO dbo.Referral
                                (PatientID, SpecialistID, PrimaryID, DateIssued, RefStatus, DeletionFlag)
                                OUTPUT INSERTED.ReferralID INTO @NewReferral (ReferralID)
                                VALUES
                                (@PatientID, @SpecialistID, @DoctorID,
                                CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time' AS DATE),
                                'Scheduled', 0);
                                SELECT ReferralID FROM @NewReferral;
                                """;
        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = request.PatientID!.Value;
        command.Parameters.Add("@SpecialistID", SqlDbType.Int).Value = request.SpecialistID!.Value;
        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;

        var result = await command.ExecuteScalarAsync(cancellationToken);   // trigger 50004 runs here

        if (result is not int id)
            throw new InvalidOperationException("Could not retrieve the new referral ID.");

        return id;
    }
    
}