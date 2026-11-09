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

    // The nurse's vitals, any saved notes, the patient's allergies and this visit's prescriptions.
    // Returns null if the nurse has not recorded vitals yet.
    public async Task<VisitRecordResponse?> GetRecordAsync(
        int appointmentId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        // Three result sets: the record, the patient's allergies, the visit's prescriptions
        command.CommandText = """
                            SELECT mr.RecordID, mr.SystolicBP, mr.DiastolicBP, mr.HeartRate, mr.Temperature,
                                   mr.WeightPounds, mr.HeightInches,
                                   mr.ClinicalNotes, mr.TreatmentPlan, mr.FollowUp
                            FROM dbo.MedicalRecord AS mr
                            WHERE mr.AppointmentID = @AppointmentID
                              AND mr.DeletionFlag = 0;

                            SELECT al.AllergyID, al.Allergen, al.ReactionType, al.Severity, al.DateIdentified
                            FROM dbo.Allergy AS al
                            JOIN dbo.Appointment AS a ON a.PatientID = al.PatientID
                            WHERE a.AppointmentID = @AppointmentID
                              AND al.DeletionFlag = 0
                            ORDER BY al.Allergen;

                            SELECT p.PrescriptionID, p.MedicationName, p.Dosage, p.Frequency,
                                   p.Duration, p.Instructions, p.Pharmacy
                            FROM dbo.Prescription AS p
                            JOIN dbo.MedicalRecord AS mr ON mr.RecordID = p.RecordID
                            WHERE mr.AppointmentID = @AppointmentID
                              AND p.DeletionFlag = 0
                              AND mr.DeletionFlag = 0
                            ORDER BY p.PrescriptionID;
                            """;

        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        var record = new VisitRecordResponse
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

        // Result set 2: allergies
        await reader.NextResultAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            record.Allergies.Add(new AllergyRow
            {
                AllergyID = reader.GetInt32(reader.GetOrdinal("AllergyID")),
                Allergen = reader.GetString(reader.GetOrdinal("Allergen")),
                ReactionType = reader.GetString(reader.GetOrdinal("ReactionType")),
                Severity = reader.GetString(reader.GetOrdinal("Severity")),
                DateIdentified = reader.IsDBNull(reader.GetOrdinal("DateIdentified"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("DateIdentified"))
            });
        }

        // Result set 3: prescriptions for this visit
        await reader.NextResultAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            int instructions = reader.GetOrdinal("Instructions");
            int pharmacy = reader.GetOrdinal("Pharmacy");

            record.Prescriptions.Add(new VisitPrescriptionRow
            {
                PrescriptionID = reader.GetInt32(reader.GetOrdinal("PrescriptionID")),
                MedicationName = reader.GetString(reader.GetOrdinal("MedicationName")),
                Dosage = reader.GetString(reader.GetOrdinal("Dosage")),
                Frequency = reader.GetString(reader.GetOrdinal("Frequency")),
                Duration = reader.GetString(reader.GetOrdinal("Duration")),
                Instructions = reader.IsDBNull(instructions) ? null : reader.GetString(instructions),
                Pharmacy = reader.IsDBNull(pharmacy) ? null : reader.GetString(pharmacy)
            });
        }

        return record;
    }

    // Drug families: an allergy to the first word also matches these medication names
    private static readonly Dictionary<string, string[]> RelatedMedications = new(StringComparer.OrdinalIgnoreCase)
    {
        ["penicillin"] = new[] { "penicillin", "amoxicillin", "ampicillin", "augmentin", "dicloxacillin" },
        ["sulfa"] = new[] { "sulfamethoxazole", "bactrim", "sulfasalazine" },
        ["aspirin"] = new[] { "aspirin", "ibuprofen", "naproxen", "advil", "aleve" },
        ["codeine"] = new[] { "codeine", "hydrocodone", "oxycodone", "morphine" },
    };

    // The patient's allergies that match this medication, as "Penicillin (Severe, Hives)"
    public async Task<List<string>> GetAllergyConflictsAsync(
        int appointmentId,
        string medicationName,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText = """
                            SELECT al.Allergen, al.ReactionType, al.Severity
                            FROM dbo.Allergy AS al
                            JOIN dbo.Appointment AS a ON a.PatientID = al.PatientID
                            WHERE a.AppointmentID = @AppointmentID
                              AND al.DeletionFlag = 0;
                            """;
        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;

        string medication = medicationName.Trim().ToLowerInvariant();
        var conflicts = new List<string>();

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            string allergen = reader.GetString(0);
            string a = allergen.Trim().ToLowerInvariant();

            bool sameName = medication.Contains(a) || a.Contains(medication);
            bool sameFamily = RelatedMedications.TryGetValue(a, out var related)
                              && related.Any(r => medication.Contains(r));

            if (sameName || sameFamily)
            {
                conflicts.Add($"{allergen} ({reader.GetString(2)}, {reader.GetString(1)})");
            }
        }

        return conflicts;
    }

    // Adds a prescription to the visit's medical record. PrescriptionID counts 1, 2, 3 ... per record
    // (Prescription is a weak entity of MedicalRecord). Returns null when the visit has no record yet
    // or is not this doctor's.
    public async Task<int?> AddPrescriptionAsync(
        int doctorId,
        int appointmentId,
        CreatePrescriptionRequest request,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        using var transaction = connection.BeginTransaction();

        using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
                            DECLARE @RecordID INT =
                                (SELECT mr.RecordID
                                 FROM dbo.MedicalRecord AS mr
                                 JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
                                 WHERE mr.AppointmentID = @AppointmentID
                                   AND a.DoctorID = @DoctorID
                                   AND mr.DeletionFlag = 0
                                   AND a.DeletionFlag = 0);

                            IF @RecordID IS NULL
                            BEGIN
                                SELECT CAST(NULL AS INT);
                                RETURN;
                            END;

                            DECLARE @NextID INT =
                                (SELECT ISNULL(MAX(PrescriptionID), 0) + 1
                                 FROM dbo.Prescription WITH (UPDLOCK, HOLDLOCK)
                                 WHERE RecordID = @RecordID);

                            INSERT INTO dbo.Prescription
                                (PrescriptionID, RecordID, MedicationName, Dosage, Frequency,
                                 Duration, Instructions, Pharmacy, DeletionFlag)
                            VALUES
                                (@NextID, @RecordID, @MedicationName, @Dosage, @Frequency,
                                 @Duration, @Instructions, @Pharmacy, 0);

                            SELECT @NextID;
                            """;

        command.Parameters.Add("@DoctorID", SqlDbType.Int).Value = doctorId;
        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;
        command.Parameters.Add("@MedicationName", SqlDbType.VarChar, 50).Value = request.MedicationName.Trim();
        command.Parameters.Add("@Dosage", SqlDbType.VarChar, 20).Value = request.Dosage.Trim();
        command.Parameters.Add("@Frequency", SqlDbType.VarChar, 20).Value = request.Frequency.Trim();
        command.Parameters.Add("@Duration", SqlDbType.VarChar, 20).Value = request.Duration.Trim();
        command.Parameters.Add("@Instructions", SqlDbType.VarChar, 100).Value = ToDbValue(request.Instructions);
        command.Parameters.Add("@Pharmacy", SqlDbType.VarChar, 60).Value = request.Pharmacy.Trim();

        var result = await command.ExecuteScalarAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        return result is int id ? id : null;
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
