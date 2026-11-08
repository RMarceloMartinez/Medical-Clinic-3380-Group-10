using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

// Database work for the doctor's "My visits" page. The doctor's ID comes from the login
// (the controller passes it in), never from the browser.
public class DoctorService
{
    // "Today" must be the clinic's date, not the server's: Azure servers run in UTC
    private const string ClinicTimeZoneId = "America/Chicago";

    private readonly SqlConnectionFactory _connectionFactory;

    public DoctorService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // The doctor's own visits. range: "today" = today only, "week" = today plus the next 6 days.
    // Cancelled visits are left out; completed ones stay so the doctor can see what was finished.
    public async Task<List<DoctorVisitRow>> GetVisitsAsync(
        int doctorId,
        string range,
        CancellationToken cancellationToken = default)
    {
        var clinicNow = TimeZoneInfo.ConvertTime(
            DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById(ClinicTimeZoneId));

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                            SELECT a.AppointmentID,
                                   a.PatientID,
                                   a.Date_Time,
                                   a.AppointStatus,
                                   p.FirstName + ' ' + p.LastName AS PatientName,
                                   o.StreetAddress + ', ' + o.City AS OfficeAddress,
                                   CASE WHEN mr.RecordID IS NULL THEN 0 ELSE 1 END AS VitalsRecorded
                            FROM dbo.Appointment AS a
                            JOIN dbo.Member AS p ON p.MemberID = a.PatientID
                            JOIN dbo.Office AS o ON o.OfficeID = a.OfficeID
                            LEFT JOIN dbo.MedicalRecord AS mr
                                ON mr.AppointmentID = a.AppointmentID
                               AND mr.DeletionFlag = 0
                            WHERE a.DoctorID = @DoctorID
                              AND a.AppointStatus <> 'Cancelled'
                              AND a.DeletionFlag = 0
                              AND a.Date_Time >= @From
                              AND a.Date_Time <  DATEADD(DAY, @Days, @From)
                            ORDER BY a.Date_Time;
                            """;

        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;
        command.Parameters.Add("@From", SqlDbType.Date).Value = clinicNow.Date;
        command.Parameters.Add("@Days", SqlDbType.Int).Value = range == "week" ? 7 : 1;

        var visits = new List<DoctorVisitRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            visits.Add(new DoctorVisitRow
            {
                AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
                PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
                AppointmentDateTime = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
                AppointStatus = reader.GetString(reader.GetOrdinal("AppointStatus")),
                PatientName = reader.GetString(reader.GetOrdinal("PatientName")),
                OfficeAddress = reader.GetString(reader.GetOrdinal("OfficeAddress")),
                VitalsRecorded = reader.GetInt32(reader.GetOrdinal("VitalsRecorded")) == 1
            });
        }

        return visits;
    }

    // Which doctor a visit belongs to, or null if the visit does not exist.
    // The controller uses this to answer 404 (no such visit) or 403 (someone else's visit).
    public async Task<int?> GetVisitDoctorIdAsync(
        int appointmentId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                            SELECT DoctorID
                            FROM dbo.Appointment
                            WHERE AppointmentID = @AppointmentID
                              AND DeletionFlag = 0;
                            """;

        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;

        var result = await command.ExecuteScalarAsync(cancellationToken);

        return result is int id ? id : null;
    }

    // The nurse's vitals and any saved notes. Returns null if the nurse has not recorded vitals yet.
    public async Task<VisitRecordResponse?> GetRecordAsync(
        int appointmentId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                            SELECT SystolicBP, DiastolicBP, HeartRate, Temperature,
                                   WeightPounds, HeightInches,
                                   ClinicalNotes, TreatmentPlan, FollowUp
                            FROM dbo.MedicalRecord
                            WHERE AppointmentID = @AppointmentID
                              AND DeletionFlag = 0;
                            """;

        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return new VisitRecordResponse
        {
            SystolicBP = reader.GetInt16(reader.GetOrdinal("SystolicBP")),
            DiastolicBP = reader.GetInt16(reader.GetOrdinal("DiastolicBP")),
            HeartRate = reader.GetInt16(reader.GetOrdinal("HeartRate")),
            Temperature = reader.GetDecimal(reader.GetOrdinal("Temperature")),
            WeightPounds = reader.GetDecimal(reader.GetOrdinal("WeightPounds")),
            HeightInches = reader.GetDecimal(reader.GetOrdinal("HeightInches")),
            ClinicalNotes = reader.IsDBNull(reader.GetOrdinal("ClinicalNotes"))
                ? null
                : reader.GetString(reader.GetOrdinal("ClinicalNotes")),
            TreatmentPlan = reader.IsDBNull(reader.GetOrdinal("TreatmentPlan"))
                ? null
                : reader.GetString(reader.GetOrdinal("TreatmentPlan")),
            FollowUp = reader.IsDBNull(reader.GetOrdinal("FollowUp"))
                ? null
                : reader.GetString(reader.GetOrdinal("FollowUp"))
        };
    }

    // Saves the three notes fields on the visit's existing record (blank text is stored as NULL).
    // Returns false when nothing was updated: no record yet, or the visit is not this doctor's.
    // Only the notes change, so the nurse's vitals are left alone.
    public async Task<bool> SaveNotesAsync(
        int doctorId,
        int appointmentId,
        SaveNotesRequest request,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                            UPDATE mr
                            SET mr.ClinicalNotes = @ClinicalNotes,
                                mr.TreatmentPlan = @TreatmentPlan,
                                mr.FollowUp = @FollowUp
                            FROM dbo.MedicalRecord AS mr
                            JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
                            WHERE mr.AppointmentID = @AppointmentID
                              AND mr.DeletionFlag = 0
                              AND a.DoctorID = @DoctorID
                              AND a.DeletionFlag = 0;
                            """;

        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;
        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;
        command.Parameters.Add("@ClinicalNotes", SqlDbType.VarChar, 500).Value = ToDbValue(request.ClinicalNotes);
        command.Parameters.Add("@TreatmentPlan", SqlDbType.VarChar, 200).Value = ToDbValue(request.TreatmentPlan);
        command.Parameters.Add("@FollowUp", SqlDbType.VarChar, 200).Value = ToDbValue(request.FollowUp);

        int rowsChanged = await command.ExecuteNonQueryAsync(cancellationToken);

        return rowsChanged > 0;
    }

    // Blank text becomes NULL in the database
    private static object ToDbValue(string? text) =>
        string.IsNullOrWhiteSpace(text) ? DBNull.Value : (object)text.Trim();
}
