using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;

namespace ClinicApi.Services;

public class PatientService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public PatientService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<PatientResponse?> GetByIdAsync(
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
            SELECT p.PatientID,
                   m.FirstName, m.MiddleName, m.LastName,
                   m.StreetAddress, m.ApartmentNum,
                   m.City, m.State, m.ZipCode, m.Country,
                   m.Phone, m.Sex, m.DateOfBirth, m.Email
            FROM dbo.Patient AS p
            INNER JOIN dbo.Member AS m
                ON m.MemberID = p.PatientID
            WHERE p.PatientID = @PatientID
              AND p.DeletionFlag = 0
              AND m.DeletionFlag = 0;
            """;

        command.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        using var reader =
            await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return new PatientResponse
        {
            PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
            FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
            MiddleName = reader.IsDBNull(reader.GetOrdinal("MiddleName"))
                ? null
                : reader.GetString(reader.GetOrdinal("MiddleName")),
            LastName = reader.GetString(reader.GetOrdinal("LastName")),
            StreetAddress =
                reader.GetString(reader.GetOrdinal("StreetAddress")),
            ApartmentNum = reader.IsDBNull(reader.GetOrdinal("ApartmentNum"))
                ? null
                : reader.GetString(reader.GetOrdinal("ApartmentNum")),
            City = reader.GetString(reader.GetOrdinal("City")),
            State = reader.GetString(reader.GetOrdinal("State")),
            ZipCode = reader.GetString(reader.GetOrdinal("ZipCode")),
            Country = reader.GetString(reader.GetOrdinal("Country")),
            Phone = reader.GetString(reader.GetOrdinal("Phone")),
            Sex = reader.GetString(reader.GetOrdinal("Sex")),
            DateOfBirth = DateOnly.FromDateTime(
                reader.GetDateTime(reader.GetOrdinal("DateOfBirth"))),
            Email = reader.GetString(reader.GetOrdinal("Email"))
        };
    }

    
public async Task<List<PatientResponse>> GetAllAsync(
    CancellationToken cancellationToken = default)
{
    var patients = new List<PatientResponse>();

    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        SELECT p.PatientID,
               m.FirstName, m.MiddleName, m.LastName,
               m.StreetAddress, m.ApartmentNum,
               m.City, m.State, m.ZipCode, m.Country,
               m.Phone, m.Sex, m.DateOfBirth, m.Email
        FROM dbo.Patient AS p
        INNER JOIN dbo.Member AS m
            ON m.MemberID = p.PatientID
        WHERE p.DeletionFlag = 0
          AND m.DeletionFlag = 0
        ORDER BY m.LastName, m.FirstName;
        """;

    using var reader =
        await command.ExecuteReaderAsync(cancellationToken);

    while (await reader.ReadAsync(cancellationToken))
    {
        patients.Add(new PatientResponse
        {
            PatientID = reader.GetInt32(reader.GetOrdinal("PatientID")),
            FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
            MiddleName = reader.IsDBNull(reader.GetOrdinal("MiddleName"))
                ? null
                : reader.GetString(reader.GetOrdinal("MiddleName")),
            LastName = reader.GetString(reader.GetOrdinal("LastName")),
            StreetAddress = reader.GetString(reader.GetOrdinal("StreetAddress")),
            ApartmentNum = reader.IsDBNull(reader.GetOrdinal("ApartmentNum"))
                ? null
                : reader.GetString(reader.GetOrdinal("ApartmentNum")),
            City = reader.GetString(reader.GetOrdinal("City")),
            State = reader.GetString(reader.GetOrdinal("State")),
            ZipCode = reader.GetString(reader.GetOrdinal("ZipCode")),
            Country = reader.GetString(reader.GetOrdinal("Country")),
            Phone = reader.GetString(reader.GetOrdinal("Phone")),
            Sex = reader.GetString(reader.GetOrdinal("Sex")),
            DateOfBirth = DateOnly.FromDateTime(
                reader.GetDateTime(reader.GetOrdinal("DateOfBirth"))),
            Email = reader.GetString(reader.GetOrdinal("Email"))
        });
    }

    return patients;
}


    public async Task<int> CreateAsync(
        CreatePatientRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.DateOfBirth is null)
        {
            throw new ArgumentException("Date of birth is required.");
        }

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var transaction = connection.BeginTransaction();

        using var doctorCommand = connection.CreateCommand();
        doctorCommand.Transaction = transaction;

        doctorCommand.CommandText = """
                                    SELECT COUNT(*)
                                    FROM dbo.Doctor AS d
                                    JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
                                    JOIN dbo.Specialty AS s ON s.SpecialtyName = d.Specialty
                                    WHERE d.DoctorID = @DoctorID
                                    AND s.IsPrimaryCare = 1
                                    AND d.DeletionFlag = 0
                                    AND m.DeletionFlag = 0
                                    AND s.DeletionFlag = 0
                                    """;
        doctorCommand.Parameters.Add("@DoctorID",SqlDbType.Int)
            .Value = request.PrimaryDoctorID;

        if(await doctorCommand.ExecuteScalarAsync(cancellationToken) is not int
        doctorCount || doctorCount == 0)
        {
            throw new ArgumentException("Pick a Primary Care Doctor from the list.");
        }

        using var memberCommand = connection.CreateCommand();
        memberCommand.Transaction = transaction;

        memberCommand.CommandText = """
            INSERT INTO dbo.Member
            (
                SSN, FirstName, MiddleName, LastName,
                StreetAddress, ApartmentNum,
                City, State, ZipCode, Country,
                Phone, Sex, DateOfBirth, Email, DeletionFlag
            )
            OUTPUT INSERTED.MemberID
            VALUES
            (
                @SSN, @FirstName, @MiddleName, @LastName,
                @StreetAddress, @ApartmentNum,
                @City, @State, @ZipCode, @Country,
                @Phone, @Sex, @DateOfBirth, @Email, 0
            );
            """;

        memberCommand.Parameters.Add("@SSN", SqlDbType.VarChar, 11)
            .Value = string.IsNullOrWhiteSpace(request.SSN)
                ? DBNull.Value
                : request.SSN;

        memberCommand.Parameters.Add("@FirstName", SqlDbType.VarChar, 15)
            .Value = request.FirstName;

        memberCommand.Parameters.Add("@MiddleName", SqlDbType.VarChar, 15)
            .Value = string.IsNullOrWhiteSpace(request.MiddleName)
                ? DBNull.Value
                : request.MiddleName;

        memberCommand.Parameters.Add("@LastName", SqlDbType.VarChar, 31)
            .Value = request.LastName;

        memberCommand.Parameters.Add("@StreetAddress", SqlDbType.VarChar, 80)
            .Value = request.StreetAddress;

        memberCommand.Parameters.Add("@ApartmentNum", SqlDbType.VarChar, 5)
            .Value = string.IsNullOrWhiteSpace(request.ApartmentNum)
                ? DBNull.Value
                : request.ApartmentNum;

        memberCommand.Parameters.Add("@City", SqlDbType.VarChar, 48)
            .Value = request.City;

        memberCommand.Parameters.Add("@State", SqlDbType.VarChar, 20)
            .Value = request.State;

        memberCommand.Parameters.Add("@ZipCode", SqlDbType.VarChar, 5)
            .Value = request.ZipCode;

        memberCommand.Parameters.Add("@Country", SqlDbType.VarChar, 56)
            .Value = request.Country;

        memberCommand.Parameters.Add("@Phone", SqlDbType.VarChar, 10)
            .Value = request.Phone;

        memberCommand.Parameters.Add("@Sex", SqlDbType.Char, 1)
            .Value = request.Sex;

        memberCommand.Parameters.Add("@DateOfBirth", SqlDbType.Date)
            .Value = request.DateOfBirth.Value.ToDateTime(TimeOnly.MinValue);

        memberCommand.Parameters.Add("@Email", SqlDbType.VarChar, 100)
            .Value = request.Email;

        var result = await memberCommand.ExecuteScalarAsync(cancellationToken);

        if (result is not int patientId)
        {
            throw new InvalidOperationException(
                "The database did not return a new member ID.");
        }

        using var patientCommand = connection.CreateCommand();
        patientCommand.Transaction = transaction;

        patientCommand.CommandText = """
            INSERT INTO dbo.Patient (PatientID, DeletionFlag)
            VALUES (@PatientID, 0);
            """;

        patientCommand.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        await patientCommand.ExecuteNonQueryAsync(cancellationToken);

        using var careCommand = connection.CreateCommand();
        careCommand.Transaction = transaction;

        careCommand.CommandText = """
                                INSERT INTO dbo.PatientDoctor
                                (PatientID, DoctorID, RolePlayed, StartDate, DeletionFlag)
                                VALUES
                                (@PatientID, @DoctorID, 'Primary', CAST(GETDATE() AS DATE), 0);
                                """;
        careCommand.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
        careCommand.Parameters.Add("@DoctorID", SqlDbType.Int).Value = request.PrimaryDoctorID;

        await careCommand.ExecuteNonQueryAsync(cancellationToken);

        await transaction.CommitAsync(cancellationToken);

        return patientId;
    }

    public async Task<bool> UpdateAsync(
        int patientId,
        UpdatePatientRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.DateOfBirth is null)
        {
            throw new ArgumentException("Date of birth is required.");
        }

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
            SET NOCOUNT ON;

            UPDATE m
            SET
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                StreetAddress = @StreetAddress,
                ApartmentNum = @ApartmentNum,
                City = @City,
                State = @State,
                ZipCode = @ZipCode,
                Country = @Country,
                Phone = @Phone,
                Sex = @Sex,
                DateOfBirth = @DateOfBirth,
                Email = @Email
            FROM dbo.Member AS m
            INNER JOIN dbo.Patient AS p
                ON p.PatientID = m.MemberID
            WHERE p.PatientID = @PatientID
                AND p.DeletionFlag = 0
                AND m.DeletionFlag = 0;

            SELECT @@ROWCOUNT;
            """;

        command.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        command.Parameters.Add("@FirstName", SqlDbType.VarChar, 15)
            .Value = request.FirstName;

        command.Parameters.Add("@MiddleName", SqlDbType.VarChar, 15)
            .Value = string.IsNullOrWhiteSpace(request.MiddleName)
                ? DBNull.Value
                : request.MiddleName;

        command.Parameters.Add("@LastName", SqlDbType.VarChar, 31)
            .Value = request.LastName;

        command.Parameters.Add("@StreetAddress", SqlDbType.VarChar, 80)
            .Value = request.StreetAddress;

        command.Parameters.Add("@ApartmentNum", SqlDbType.VarChar, 5)
            .Value = string.IsNullOrWhiteSpace(request.ApartmentNum)
                ? DBNull.Value
                : request.ApartmentNum;

        command.Parameters.Add("@City", SqlDbType.VarChar, 48)
            .Value = request.City;

        command.Parameters.Add("@State", SqlDbType.VarChar, 20)
            .Value = request.State;

        command.Parameters.Add("@ZipCode", SqlDbType.VarChar, 5)
            .Value = request.ZipCode;

        command.Parameters.Add("@Country", SqlDbType.VarChar, 56)
            .Value = request.Country;

        command.Parameters.Add("@Phone", SqlDbType.VarChar, 10)
            .Value = request.Phone;

        command.Parameters.Add("@Sex", SqlDbType.Char, 1)
            .Value = request.Sex;

        command.Parameters.Add("@DateOfBirth", SqlDbType.Date)
            .Value = request.DateOfBirth.Value.ToDateTime(TimeOnly.MinValue);

        command.Parameters.Add("@Email", SqlDbType.VarChar, 100)
            .Value = request.Email;

        var result = await command.ExecuteScalarAsync(cancellationToken);

        return result is int rowsUpdated && rowsUpdated == 1;
    }

    public async Task<bool> DeactivateAsync(
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
            SET NOCOUNT ON;

            UPDATE dbo.Patient
            SET DeletionFlag = 1
            WHERE PatientID = @PatientID
              AND DeletionFlag = 0;

            SELECT @@ROWCOUNT;
            """;

        command.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        var result = await command.ExecuteScalarAsync(cancellationToken);

        return result is int rowsUpdated && rowsUpdated == 1;
    }
        public async Task<StaffPatientChartResponse?> GetStaffChartAsync(
        int patientId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var chart = new StaffPatientChartResponse();

        using var command = connection.CreateCommand();

        command.CommandText = """
            -- 1. Patient identity
            SELECT p.PatientID,
                   m.FirstName + ' ' + m.LastName AS PatientName
            FROM dbo.Patient AS p
            JOIN dbo.Member AS m ON m.MemberID = p.PatientID
            WHERE p.PatientID = @PatientID
              AND p.DeletionFlag = 0
              AND m.DeletionFlag = 0;

            -- 2. Allergies
            SELECT AllergyID, Allergen, ReactionType, Severity, DateIdentified
            FROM dbo.Allergy
            WHERE PatientID = @PatientID
              AND DeletionFlag = 0
            ORDER BY Allergen;

            -- 3. Conditions
            SELECT ConditionID, ConditionName, ConditionType,
                   Severity, IsHereditary, DateDiagnosed
            FROM dbo.PatientCondition
            WHERE PatientID = @PatientID
              AND DeletionFlag = 0
            ORDER BY ConditionName;

            -- 4. Visits and medical record data
            SELECT a.AppointmentID,
                   a.Date_Time,
                   a.AppointStatus,
                   a.VisitReason,
                   mr.SystolicBP,
                   mr.DiastolicBP,
                   mr.HeartRate,
                   mr.Temperature,
                   mr.WeightPounds,
                   mr.HeightInches,
                   mr.NursingNotes,
                   mr.ClinicalNotes
            FROM dbo.Appointment AS a
            LEFT JOIN dbo.MedicalRecord AS mr
                ON mr.AppointmentID = a.AppointmentID
               AND mr.DeletionFlag = 0
            WHERE a.PatientID = @PatientID
              AND a.DeletionFlag = 0
            ORDER BY a.Date_Time DESC;

            -- 5. Diagnoses
            SELECT a.AppointmentID,
                   d.DiagnosisID,
                   d.DiagnosisDescription,
                   d.DiagnosisType
            FROM dbo.Appointment AS a
            JOIN dbo.MedicalRecord AS mr
                ON mr.AppointmentID = a.AppointmentID
               AND mr.DeletionFlag = 0
            JOIN dbo.Diagnosis AS d
                ON d.RecordID = mr.RecordID
               AND d.DeletionFlag = 0
            WHERE a.PatientID = @PatientID
              AND a.DeletionFlag = 0;

            -- 6. Prescriptions
            SELECT a.AppointmentID,
                   p.PrescriptionID,
                   p.MedicationName,
                   p.Dosage,
                   p.Frequency,
                   p.Duration,
                   p.Instructions,
                   p.Pharmacy
            FROM dbo.Appointment AS a
            JOIN dbo.MedicalRecord AS mr
                ON mr.AppointmentID = a.AppointmentID
               AND mr.DeletionFlag = 0
            JOIN dbo.Prescription AS p
                ON p.RecordID = mr.RecordID
               AND p.DeletionFlag = 0
            WHERE a.PatientID = @PatientID
              AND a.DeletionFlag = 0;
            """;

        command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        // Result set 1: patient identity
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        chart.PatientID = reader.GetInt32(reader.GetOrdinal("PatientID"));
        chart.PatientName = reader.GetString(reader.GetOrdinal("PatientName"));

        // Result set 2: allergies
        await reader.NextResultAsync(cancellationToken);

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

        // Result set 3: conditions
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

        // Result set 4: visits
        await reader.NextResultAsync(cancellationToken);

        var visitsByAppointmentId = new Dictionary<int, StaffChartVisit>();

        while (await reader.ReadAsync(cancellationToken))
        {
            int appointmentId =
                reader.GetInt32(reader.GetOrdinal("AppointmentID"));

            var visit = new StaffChartVisit
            {
                AppointmentID = appointmentId,
                VisitDate = reader.GetDateTime(reader.GetOrdinal("Date_Time")),
                AppointmentStatus =
                    reader.GetString(reader.GetOrdinal("AppointStatus")),

                VisitReason = reader.IsDBNull(reader.GetOrdinal("VisitReason"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("VisitReason")),

                SystolicBP = reader.IsDBNull(reader.GetOrdinal("SystolicBP"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("SystolicBP")),

                DiastolicBP = reader.IsDBNull(reader.GetOrdinal("DiastolicBP"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("DiastolicBP")),

                HeartRate = reader.IsDBNull(reader.GetOrdinal("HeartRate"))
                    ? null
                    : reader.GetInt16(reader.GetOrdinal("HeartRate")),

                Temperature = reader.IsDBNull(reader.GetOrdinal("Temperature"))
                    ? null
                    : reader.GetDecimal(reader.GetOrdinal("Temperature")),

                WeightPounds = reader.IsDBNull(reader.GetOrdinal("WeightPounds"))
                    ? null
                    : reader.GetDecimal(reader.GetOrdinal("WeightPounds")),

                HeightInches = reader.IsDBNull(reader.GetOrdinal("HeightInches"))
                    ? null
                    : reader.GetDecimal(reader.GetOrdinal("HeightInches")),

                NursingNotes = reader.IsDBNull(reader.GetOrdinal("NursingNotes"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("NursingNotes")),

                DoctorNotes = reader.IsDBNull(reader.GetOrdinal("ClinicalNotes"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("ClinicalNotes"))
            };

            chart.Visits.Add(visit);
            visitsByAppointmentId[appointmentId] = visit;
        }

        // Result set 5: diagnoses
        await reader.NextResultAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            int appointmentId =
                reader.GetInt32(reader.GetOrdinal("AppointmentID"));

            if (visitsByAppointmentId.TryGetValue(
                appointmentId, out var visit))
            {
                visit.Diagnoses.Add(new StaffChartDiagnosis
                {
                    DiagnosisID =
                        reader.GetInt32(reader.GetOrdinal("DiagnosisID")),

                    DiagnosisDescription =
                        reader.GetString(reader.GetOrdinal("DiagnosisDescription")),

                    DiagnosisType =
                        reader.GetString(reader.GetOrdinal("DiagnosisType"))
                });
            }
        }

        // Result set 6: prescriptions
        await reader.NextResultAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            int appointmentId =
                reader.GetInt32(reader.GetOrdinal("AppointmentID"));

            if (visitsByAppointmentId.TryGetValue(
                appointmentId, out var visit))
            {
                visit.Prescriptions.Add(new StaffChartPrescription
                {
                    PrescriptionID =
                        reader.GetInt32(reader.GetOrdinal("PrescriptionID")),

                    MedicationName =
                        reader.GetString(reader.GetOrdinal("MedicationName")),

                    Dosage = reader.GetString(reader.GetOrdinal("Dosage")),
                    Frequency = reader.GetString(reader.GetOrdinal("Frequency")),
                    Duration = reader.GetString(reader.GetOrdinal("Duration")),

                    Instructions = reader.IsDBNull(reader.GetOrdinal("Instructions"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("Instructions")),

                    Pharmacy = reader.IsDBNull(reader.GetOrdinal("Pharmacy"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("Pharmacy"))
                });
            }
        }

        return chart;
    }
    public async Task<int?> AddAllergyAsync(
    int patientId,
    AllergyRequest request,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        INSERT INTO dbo.Allergy
            (PatientID, Allergen, ReactionType, Severity,
             DateIdentified, DeletionFlag)
        SELECT
            @PatientID, @Allergen, @ReactionType, @Severity,
            @DateIdentified, 0
        WHERE EXISTS (
            SELECT 1
            FROM dbo.Patient
            WHERE PatientID = @PatientID
              AND DeletionFlag = 0
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT);
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int)
        .Value = patientId;

    command.Parameters.Add("@Allergen", SqlDbType.VarChar, 60)
        .Value = request.Allergen.Trim();

    command.Parameters.Add("@ReactionType", SqlDbType.VarChar, 30)
        .Value = request.ReactionType.Trim();

    command.Parameters.Add("@Severity", SqlDbType.VarChar, 20)
        .Value = request.Severity.Trim();

    command.Parameters.Add("@DateIdentified", SqlDbType.Date)
        .Value = request.DateIdentified?.Date is DateTime date
            ? date
            : DBNull.Value;

    var result = await command.ExecuteScalarAsync(cancellationToken);

    return result == null || result == DBNull.Value
        ? null
        : Convert.ToInt32(result);
}
public async Task<bool> UpdateAllergyAsync(
    int patientId,
    int allergyId,
    AllergyRequest request,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        UPDATE dbo.Allergy
        SET Allergen = @Allergen,
            ReactionType = @ReactionType,
            Severity = @Severity,
            DateIdentified = @DateIdentified
        WHERE AllergyID = @AllergyID
          AND PatientID = @PatientID
          AND DeletionFlag = 0;
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
    command.Parameters.Add("@AllergyID", SqlDbType.Int).Value = allergyId;

    command.Parameters.Add("@Allergen", SqlDbType.VarChar, 60)
        .Value = request.Allergen.Trim();

    command.Parameters.Add("@ReactionType", SqlDbType.VarChar, 30)
        .Value = request.ReactionType.Trim();

    command.Parameters.Add("@Severity", SqlDbType.VarChar, 20)
        .Value = request.Severity.Trim();

    command.Parameters.Add("@DateIdentified", SqlDbType.Date)
        .Value = request.DateIdentified?.Date is DateTime date
            ? date
            : DBNull.Value;

    return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
}
public async Task<bool> DeleteAllergyAsync(
    int patientId,
    int allergyId,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        UPDATE dbo.Allergy
        SET DeletionFlag = 1
        WHERE AllergyID = @AllergyID
          AND PatientID = @PatientID
          AND DeletionFlag = 0;
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
    command.Parameters.Add("@AllergyID", SqlDbType.Int).Value = allergyId;

    return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
}
public async Task<int?> AddConditionAsync(
    int patientId,
    ConditionRequest request,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        INSERT INTO dbo.PatientCondition
            (PatientID, ConditionName, ConditionType, IsHereditary,
             Severity, DateDiagnosed, DeletionFlag)
        SELECT
            @PatientID, @ConditionName, @ConditionType, @IsHereditary,
            @Severity, @DateDiagnosed, 0
        WHERE EXISTS (
            SELECT 1
            FROM dbo.Patient
            WHERE PatientID = @PatientID
              AND DeletionFlag = 0
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT);
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;

    command.Parameters.Add("@ConditionName", SqlDbType.VarChar, 100)
        .Value = request.ConditionName.Trim();

    command.Parameters.Add("@ConditionType", SqlDbType.VarChar, 30)
        .Value = request.ConditionType.Trim();

    command.Parameters.Add("@IsHereditary", SqlDbType.Bit)
        .Value = request.IsHereditary;

    command.Parameters.Add("@Severity", SqlDbType.VarChar, 20)
        .Value = request.Severity.Trim();

    command.Parameters.Add("@DateDiagnosed", SqlDbType.Date)
        .Value = request.DateDiagnosed?.Date is DateTime date
            ? date
            : DBNull.Value;

    var result = await command.ExecuteScalarAsync(cancellationToken);

    return result == null || result == DBNull.Value
        ? null
        : Convert.ToInt32(result);
}
public async Task<bool> UpdateConditionAsync(
    int patientId,
    int conditionId,
    ConditionRequest request,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        UPDATE dbo.PatientCondition
        SET ConditionName = @ConditionName,
            ConditionType = @ConditionType,
            IsHereditary = @IsHereditary,
            Severity = @Severity,
            DateDiagnosed = @DateDiagnosed
        WHERE ConditionID = @ConditionID
          AND PatientID = @PatientID
          AND DeletionFlag = 0;
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
    command.Parameters.Add("@ConditionID", SqlDbType.Int).Value = conditionId;

    command.Parameters.Add("@ConditionName", SqlDbType.VarChar, 100)
        .Value = request.ConditionName.Trim();

    command.Parameters.Add("@ConditionType", SqlDbType.VarChar, 30)
        .Value = request.ConditionType.Trim();

    command.Parameters.Add("@IsHereditary", SqlDbType.Bit)
        .Value = request.IsHereditary;

    command.Parameters.Add("@Severity", SqlDbType.VarChar, 20)
        .Value = request.Severity.Trim();

    command.Parameters.Add("@DateDiagnosed", SqlDbType.Date)
        .Value = request.DateDiagnosed?.Date is DateTime date
            ? date
            : DBNull.Value;

    return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
}
public async Task<bool> DeleteConditionAsync(
    int patientId,
    int conditionId,
    CancellationToken cancellationToken = default)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync(cancellationToken);

    using var command = connection.CreateCommand();

    command.CommandText = """
        UPDATE dbo.PatientCondition
        SET DeletionFlag = 1
        WHERE ConditionID = @ConditionID
          AND PatientID = @PatientID
          AND DeletionFlag = 0;
        """;

    command.Parameters.Add("@PatientID", SqlDbType.Int).Value = patientId;
    command.Parameters.Add("@ConditionID", SqlDbType.Int).Value = conditionId;

    return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
}
}