using ClinicApi.Data;
using System.Data;

namespace ClinicApi.Services;

public class PatientMedicalRecordService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public PatientMedicalRecordService(
        SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<List<PatientMedicalRecordRow>> GetRecordsAsync(
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
        SELECT
            a.AppointmentID,
            a.Date_Time AS VisitDate,
            a.VisitReason,
            CONCAT(m.FirstName, ' ', m.LastName) AS DoctorName,
            mr.RecordID,
            mr.TreatmentPlan,
            mr.FollowUp,
            d.DiagnosisDescription,
            p.MedicationName,
            p.Dosage,
            p.Frequency,
            p.Duration,
            p.Pharmacy
        FROM dbo.Appointment a
        JOIN dbo.Doctor doc
            ON a.DoctorID = doc.DoctorID
        JOIN dbo.Member m
            ON doc.DoctorID = m.MemberID
        LEFT JOIN dbo.MedicalRecord mr
            ON a.AppointmentID = mr.AppointmentID
            AND mr.DeletionFlag = 0
        LEFT JOIN dbo.Diagnosis d
            ON mr.RecordID = d.RecordID
            AND d.DeletionFlag = 0
        LEFT JOIN dbo.Prescription p
            ON mr.RecordID = p.RecordID
            AND p.DeletionFlag = 0
        WHERE a.PatientID = @PatientID
          AND a.AppointStatus = 'Completed'
          AND a.DeletionFlag = 0
        ORDER BY a.Date_Time DESC;
        """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

        var records = new List<PatientMedicalRecordRow>();

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            records.Add(new PatientMedicalRecordRow
            {
                AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
                VisitDate = reader.GetDateTime(reader.GetOrdinal("VisitDate")),
                VisitReason = reader["VisitReason"] as string,
                DoctorName = reader.GetString(reader.GetOrdinal("DoctorName")),
                TreatmentPlan = reader["TreatmentPlan"] as string,
                FollowUp = reader["FollowUp"] as string,
                Diagnosis = reader["DiagnosisDescription"] as string,
                MedicationName = reader["MedicationName"] as string,
                Dosage = reader["Dosage"] as string,
                Frequency = reader["Frequency"] as string,
                Duration = reader["Duration"] as string,
                Pharmacy = reader["Pharmacy"] as string
            });
        }

        return records;
    }

}

public class PatientMedicalRecordRow
{
    public int AppointmentID { get; set; }
    public DateTime VisitDate { get; set; }
    public string? VisitReason { get; set; }
    public string DoctorName { get; set; } = "";
    public string? TreatmentPlan { get; set; }
    public string? FollowUp { get; set; }
    public string? Diagnosis { get; set; }
    public string? MedicationName { get; set; }
    public string? Dosage { get; set; }
    public string? Frequency { get; set; }
    public string? Duration { get; set; }
    public string? Pharmacy { get; set; }
}
