using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

// Database work for the nurse pages. The nurse's ID comes from the login (the controller
// passes it in), and their office is looked up from dbo.Nurse, never taken from the browser.
public class NurseService
{
    // "Today" must be the clinic's date, not the server's: Azure servers run in UTC
    private const string ClinicTimeZoneId = "America/Chicago";

    private readonly SqlConnectionFactory _connectionFactory;

    public NurseService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // range: "today" = today only, "week" = today plus the next 6 days
    public async Task<List<NurseVisitRow>> GetVisitsAsync(
        int nurseId,
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
                                   p.FirstName + ' ' + p.LastName AS PatientName,
                                   d.FirstName + ' ' + d.LastName AS DoctorName,
                                   CASE WHEN mr.RecordID IS NULL THEN 0 ELSE 1 END AS VitalsRecorded
                            FROM dbo.Nurse AS n
                            JOIN dbo.Appointment AS a ON a.OfficeID = n.OfficeID
                            JOIN dbo.Member AS p ON p.MemberID = a.PatientID
                            JOIN dbo.Member AS d ON d.MemberID = a.DoctorID
                            LEFT JOIN dbo.MedicalRecord AS mr
                                ON mr.AppointmentID = a.AppointmentID
                               AND mr.DeletionFlag = 0
                            WHERE n.NurseID = @NurseID
                              AND n.DeletionFlag = 0
                              AND a.AppointStatus = 'Scheduled'
                              AND a.DeletionFlag = 0
                              AND a.Date_Time >= @From
                              AND a.Date_Time <  DATEADD(DAY, @Days, @From)
                            ORDER BY a.Date_Time;
                            """;

        command.Parameters.Add("@NurseID", SqlDbType.Int).Value = nurseId;
        command.Parameters.Add("@From", SqlDbType.Date).Value = clinicNow.Date;
        command.Parameters.Add("@Days", SqlDbType.Int).Value = range == "week" ? 7 : 1;

        var visits = new List<NurseVisitRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            visits.Add(new NurseVisitRow
            {
                AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
                PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
                AppointmentDateTime = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
                PatientName = reader.GetString(reader.GetOrdinal("PatientName")),
                DoctorName = reader.GetString(reader.GetOrdinal("DoctorName")),
                VitalsRecorded = reader.GetInt32(reader.GetOrdinal("VitalsRecorded")) == 1
            });
        }

        return visits;
    }

    // Creates the MedicalRecord for a visit. Returns the new RecordID, or null when nothing was
    // inserted: the visit is not at this nurse's office, is not 'Scheduled', or already has a record.
    public async Task<int?> RecordVitalsAsync(
        int nurseId,
        int appointmentId,
        RecordVitalsRequest request,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        // OUTPUT ... INTO a table variable, the same way CreateAsync does it
        command.CommandText = """
                            DECLARE @NewRecord TABLE (RecordID INT);
                            INSERT INTO dbo.MedicalRecord (
                                AppointmentID, SystolicBP, DiastolicBP, HeartRate,
                                Temperature, WeightPounds, HeightInches, DeletionFlag
                            )
                            OUTPUT INSERTED.RecordID
                            INTO @NewRecord(RecordID)
                            SELECT a.AppointmentID, @SystolicBP, @DiastolicBP, @HeartRate,
                                   @Temperature, @WeightPounds, @HeightInches, 0
                            FROM dbo.Nurse AS n
                            JOIN dbo.Appointment AS a ON a.OfficeID = n.OfficeID
                            WHERE n.NurseID = @NurseID
                              AND n.DeletionFlag = 0
                              AND a.AppointmentID = @AppointmentID
                              AND a.AppointStatus = 'Scheduled'
                              AND a.DeletionFlag = 0
                              AND NOT EXISTS (
                                  SELECT 1 FROM dbo.MedicalRecord AS mr
                                  WHERE mr.AppointmentID = a.AppointmentID
                              );
                            SELECT RecordID FROM @NewRecord;
                            """;

        command.Parameters.Add("@NurseID", SqlDbType.Int).Value = nurseId;
        command.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = appointmentId;
        command.Parameters.Add("@SystolicBP", SqlDbType.SmallInt).Value = request.SystolicBP;
        command.Parameters.Add("@DiastolicBP", SqlDbType.SmallInt).Value = request.DiastolicBP;
        command.Parameters.Add("@HeartRate", SqlDbType.SmallInt).Value = request.HeartRate;
        AddDecimal(command, "@Temperature", 4, 1, request.Temperature);
        AddDecimal(command, "@WeightPounds", 5, 1, request.WeightPounds);
        AddDecimal(command, "@HeightInches", 4, 1, request.HeightInches);

        var result = await command.ExecuteScalarAsync(cancellationToken);

        return result is int id ? id : null;
    }

    // A patient's chart. Returns null when the patient has no appointment at this nurse's office.
    public async Task<PatientChartResponse?> GetPatientChartAsync(
        int nurseId,
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        // Step 1: is this patient allowed to be opened by this nurse?
        using (var check = connection.CreateCommand())
        {
            check.CommandText = """
                                SELECT CASE WHEN EXISTS (
                                    SELECT 1
                                    FROM dbo.Nurse AS n
                                    JOIN dbo.Appointment AS a ON a.OfficeID = n.OfficeID
                                    WHERE n.NurseID = @NurseID
                                      AND n.DeletionFlag = 0
                                      AND a.PatientID = @PatientID
                                      AND a.DeletionFlag = 0
                                ) THEN 1 ELSE 0 END;
                                """;

            check.Parameters.Add("@NurseID", SqlDbType.Int).Value = nurseId;
            check.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

            var allowed = await check.ExecuteScalarAsync(cancellationToken);

            if (Convert.ToInt32(allowed) != 1)
            {
                return null;
            }
        }

        // Step 2: three result sets in one round trip: allergies, conditions, past visits
        using var command = connection.CreateCommand();

        command.CommandText = """
                            SELECT AllergyID, Allergen, ReactionType, Severity, DateIdentified
                            FROM dbo.Allergy
                            WHERE PatientID = @PatientID AND DeletionFlag = 0
                            ORDER BY Allergen;

                            SELECT ConditionID, ConditionName, ConditionType, Severity, IsHereditary, DateDiagnosed
                            FROM dbo.PatientCondition
                            WHERE PatientID = @PatientID AND DeletionFlag = 0
                            ORDER BY ConditionName;

                            SELECT a.AppointmentID,
                                   a.Date_Time,
                                   d.FirstName + ' ' + d.LastName AS DoctorName,
                                   o.StreetAddress + ', ' + o.City AS Office,
                                   mr.SystolicBP,
                                   mr.DiastolicBP,
                                   mr.HeartRate,
                                   mr.WeightPounds
                            FROM dbo.Appointment AS a
                            JOIN dbo.Member AS d ON d.MemberID = a.DoctorID
                            JOIN dbo.Office AS o ON o.OfficeID = a.OfficeID
                            LEFT JOIN dbo.MedicalRecord AS mr
                                ON mr.AppointmentID = a.AppointmentID
                               AND mr.DeletionFlag = 0
                            WHERE a.PatientID = @PatientID
                              AND a.AppointStatus = 'Completed'
                              AND a.DeletionFlag = 0
                            ORDER BY a.Date_Time DESC;
                            """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

        var chart = new PatientChartResponse();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        // Result set 1: allergies
        while (await reader.ReadAsync(cancellationToken))
        {
            chart.Allergies.Add(new AllergyRow
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

        // Result set 2: conditions
        await reader.NextResultAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            chart.Conditions.Add(new ConditionRow
            {
                ConditionID = reader.GetInt32(reader.GetOrdinal("ConditionID")),
                ConditionName = reader.GetString(reader.GetOrdinal("ConditionName")),
                ConditionType = reader.GetString(reader.GetOrdinal("ConditionType")),
                Severity = reader.GetString(reader.GetOrdinal("Severity")),
                IsHereditary = reader.GetBoolean(reader.GetOrdinal("IsHereditary")),
                DateDiagnosed = reader.IsDBNull(reader.GetOrdinal("DateDiagnosed"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("DateDiagnosed"))
            });
        }

        // Result set 3: past visits
        await reader.NextResultAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            chart.PastVisits.Add(new PastVisitRow
            {
                AppointmentID = reader.GetInt32(reader.GetOrdinal("AppointmentID")),
                AppointmentDateTime = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
                DoctorName = reader.GetString(reader.GetOrdinal("DoctorName")),
                Office = reader.GetString(reader.GetOrdinal("Office")),
                SystolicBP = reader.IsDBNull(reader.GetOrdinal("SystolicBP"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("SystolicBP")),
                DiastolicBP = reader.IsDBNull(reader.GetOrdinal("DiastolicBP"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("DiastolicBP")),
                HeartRate = reader.IsDBNull(reader.GetOrdinal("HeartRate"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("HeartRate")),
                WeightPounds = reader.IsDBNull(reader.GetOrdinal("WeightPounds"))
                    ? null
                    : reader.GetDecimal(reader.GetOrdinal("WeightPounds"))
            });
        }

        return chart;
    }

    // Decimals need an explicit precision and scale, or SQL Server rounds them to whole numbers
    private static void AddDecimal(SqlCommand command, string name, byte precision, byte scale, decimal value)
    {
        var parameter = command.Parameters.Add(name, SqlDbType.Decimal);
        parameter.Precision = precision;
        parameter.Scale = scale;
        parameter.Value = value;
    }
}
