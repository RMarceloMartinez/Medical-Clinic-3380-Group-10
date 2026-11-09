
using ClinicApi.Data;
using System.Data;

namespace ClinicApi.Services;

public class ChartRequestService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public ChartRequestService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<int> CreateRequestAsync(
        int patientId,
        int doctorId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
        INSERT INTO dbo.ChartRequest
            (PatientID, DoctorID, RequestDate,
             RequestStatus, DeletionFlag)
        OUTPUT INSERTED.RequestID
        SELECT
            @PatientID,
            d.DoctorID,
            CAST(GETDATE() AS DATE),
            'Pending',
            0
        FROM dbo.Doctor d
        WHERE d.DoctorID = @DoctorID
          AND d.DeletionFlag = 0
          AND EXISTS (
              SELECT 1
              FROM dbo.Patient p
              WHERE p.PatientID = @PatientID
                AND p.DeletionFlag = 0
          )
          AND EXISTS (
              SELECT 1
              FROM dbo.Appointment a
              WHERE a.PatientID = @PatientID
                AND a.DoctorID = d.DoctorID
                AND a.AppointStatus = 'Completed'
                AND a.DeletionFlag = 0
          );
        """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;

        var result = await command.ExecuteScalarAsync(cancellationToken);

        if (result == null)
            throw new ArgumentException(
                "The selected doctor is not associated with a completed visit.");

        return Convert.ToInt32(result);
    }

    public async Task<List<ChartRequestRow>> GetRequestsAsync(
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
        SELECT
            cr.RequestID,
            cr.DoctorID,
            CONCAT(m.FirstName, ' ', m.LastName) AS DoctorName,
            cr.RequestDate,
            cr.RequestStatus
        FROM dbo.ChartRequest cr
        JOIN dbo.Doctor d
            ON cr.DoctorID = d.DoctorID
        JOIN dbo.Member m
            ON d.DoctorID = m.MemberID
        WHERE cr.PatientID = @PatientID
          AND cr.DeletionFlag = 0
        ORDER BY cr.RequestDate DESC, cr.RequestID DESC;
        """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

        var requests = new List<ChartRequestRow>();

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            requests.Add(new ChartRequestRow
            {
                RequestID = reader.GetInt32(reader.GetOrdinal("RequestID")),
                DoctorID = reader.GetInt32(reader.GetOrdinal("DoctorID")),
                DoctorName = reader.GetString(reader.GetOrdinal("DoctorName")),
                RequestDate = reader.GetDateTime(reader.GetOrdinal("RequestDate")),
                RequestStatus = reader.GetString(reader.GetOrdinal("RequestStatus"))
            });
        }

        return requests;
    }

}

public class ChartRequestRow
{
    public int RequestID { get; set; }
    public int DoctorID { get; set; }
    public string DoctorName { get; set; } = "";
    public DateTime RequestDate { get; set; }
    public string RequestStatus { get; set; } = "";
}
