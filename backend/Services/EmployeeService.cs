using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

// Database work for the admin's Staff page: list employees and add a worker with a login
public class EmployeeService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public EmployeeService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // Every active employee with their job, office and login
    public async Task<List<EmployeeRow>> ListAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT e.EmployeeID,
                   m.FirstName + ' ' + m.LastName AS Name,
                   CASE WHEN d.DoctorID IS NOT NULL THEN 'Doctor'
                        WHEN n.NurseID IS NOT NULL THEN 'Nurse'
                        WHEN r.ReceptionistID IS NOT NULL THEN 'Receptionist'
                        ELSE 'Admin' END AS Role,
                   o.StreetAddress AS Office,
                   d.Specialty,
                   (SELECT STRING_AGG(ds.DayOfWeek, ', ')
                           WITHIN GROUP (ORDER BY CHARINDEX(ds.DayOfWeek, 'MonTueWedThuFri'))
                    FROM dbo.DoctorSchedule AS ds
                    WHERE ds.DoctorID = d.DoctorID AND ds.DeletionFlag = 0) AS WorkDays,
                   ua.Username,
                   e.HiringDate
            FROM dbo.Employee AS e
            JOIN dbo.Member AS m ON m.MemberID = e.EmployeeID
            LEFT JOIN dbo.Doctor AS d ON d.DoctorID = e.EmployeeID AND d.DeletionFlag = 0
            LEFT JOIN dbo.Nurse AS n ON n.NurseID = e.EmployeeID AND n.DeletionFlag = 0
            LEFT JOIN dbo.Receptionist AS r ON r.ReceptionistID = e.EmployeeID AND r.DeletionFlag = 0
            LEFT JOIN dbo.Office AS o ON o.OfficeID = COALESCE(n.OfficeID, r.OfficeID,
                   (SELECT MIN(ds2.OfficeID) FROM dbo.DoctorSchedule AS ds2
                    WHERE ds2.DoctorID = d.DoctorID AND ds2.DeletionFlag = 0))
            LEFT JOIN dbo.UserAccount AS ua ON ua.UserID = e.EmployeeID AND ua.DeletionFlag = 0
            WHERE e.DeletionFlag = 0 AND m.DeletionFlag = 0
            ORDER BY Role, m.LastName, m.FirstName;
            """;

        var rows = new List<EmployeeRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            rows.Add(new EmployeeRow
            {
                EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                Name = reader.GetString(reader.GetOrdinal("Name")),
                Role = reader.GetString(reader.GetOrdinal("Role")),
                Office = reader.IsDBNull(reader.GetOrdinal("Office")) ? null : reader.GetString(reader.GetOrdinal("Office")),
                Specialty = reader.IsDBNull(reader.GetOrdinal("Specialty")) ? null : reader.GetString(reader.GetOrdinal("Specialty")),
                WorkDays = reader.IsDBNull(reader.GetOrdinal("WorkDays")) ? null : reader.GetString(reader.GetOrdinal("WorkDays")),
                Username = reader.IsDBNull(reader.GetOrdinal("Username")) ? null : reader.GetString(reader.GetOrdinal("Username")),
                HiringDate = reader.GetDateTime(reader.GetOrdinal("HiringDate"))
            });
        }

        return rows;
    }

    // The doctor's specialty dropdown: primary care first, with each visit fee
    public async Task<List<SpecialtyOption>> GetSpecialtiesAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT SpecialtyName, VisitFee
            FROM dbo.Specialty
            WHERE DeletionFlag = 0
            ORDER BY IsPrimaryCare DESC, SpecialtyName;
            """;

        var options = new List<SpecialtyOption>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            options.Add(new SpecialtyOption
            {
                Name = reader.GetString(reader.GetOrdinal("SpecialtyName")),
                VisitFee = reader.GetDecimal(reader.GetOrdinal("VisitFee"))
            });
        }

        return options;
    }

    // Adds the worker in ONE transaction:
    // Member -> Employee -> Doctor/Nurse/Receptionist -> DoctorSchedule (doctor) -> UserAccount
    public async Task<int> CreateAsync(
        CreateEmployeeRequest request,
        CancellationToken cancellationToken = default)
    {
        // Same bcrypt work factor as the seed accounts (11)
        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password, 11);

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var transaction = connection.BeginTransaction();

        // 1. Member row (same as the patient sign-up, but SSN is always given)
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

        memberCommand.Parameters.Add("@SSN", SqlDbType.VarChar, 11).Value = request.SSN;
        memberCommand.Parameters.Add("@FirstName", SqlDbType.VarChar, 15).Value = request.FirstName;
        memberCommand.Parameters.Add("@MiddleName", SqlDbType.VarChar, 15).Value =
            string.IsNullOrWhiteSpace(request.MiddleName) ? DBNull.Value : request.MiddleName;
        memberCommand.Parameters.Add("@LastName", SqlDbType.VarChar, 31).Value = request.LastName;
        memberCommand.Parameters.Add("@StreetAddress", SqlDbType.VarChar, 80).Value = request.StreetAddress;
        memberCommand.Parameters.Add("@ApartmentNum", SqlDbType.VarChar, 5).Value =
            string.IsNullOrWhiteSpace(request.ApartmentNum) ? DBNull.Value : request.ApartmentNum;
        memberCommand.Parameters.Add("@City", SqlDbType.VarChar, 48).Value = request.City;
        memberCommand.Parameters.Add("@State", SqlDbType.VarChar, 20).Value = request.State;
        memberCommand.Parameters.Add("@ZipCode", SqlDbType.VarChar, 5).Value = request.ZipCode;
        memberCommand.Parameters.Add("@Country", SqlDbType.VarChar, 56).Value = request.Country;
        memberCommand.Parameters.Add("@Phone", SqlDbType.VarChar, 10).Value = request.Phone;
        memberCommand.Parameters.Add("@Sex", SqlDbType.Char, 1).Value = request.Sex;
        memberCommand.Parameters.Add("@DateOfBirth", SqlDbType.Date).Value =
            request.DateOfBirth!.Value.ToDateTime(TimeOnly.MinValue);
        memberCommand.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = request.Email;

        var result = await memberCommand.ExecuteScalarAsync(cancellationToken);

        if (result is not int employeeId)
        {
            throw new InvalidOperationException("The database did not return a new member ID.");
        }

        // 2. Employee row (hiring date = today in Houston)
        using var employeeCommand = connection.CreateCommand();
        employeeCommand.Transaction = transaction;
        employeeCommand.CommandText = """
            INSERT INTO dbo.Employee (EmployeeID, HiringDate, DeletionFlag)
            VALUES (@EmployeeID, CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time' AS DATE), 0);
            """;
        employeeCommand.Parameters.Add("@EmployeeID", SqlDbType.Int).Value = employeeId;
        await employeeCommand.ExecuteNonQueryAsync(cancellationToken);

        // 3. The job row: one INSERT, picked by role
        using var jobCommand = connection.CreateCommand();
        jobCommand.Transaction = transaction;
        jobCommand.CommandText = request.Role switch
        {
            "Doctor" => """
                INSERT INTO dbo.Doctor (DoctorID, LicenseNum, Specialty, DeletionFlag)
                VALUES (@EmployeeID, @LicenseNum, @Specialty, 0);
                """,
            "Nurse" => """
                INSERT INTO dbo.Nurse (NurseID, OfficeID, LicenseNum, DeletionFlag)
                VALUES (@EmployeeID, @OfficeID, @LicenseNum, 0);
                """,
            _ => """
                INSERT INTO dbo.Receptionist (ReceptionistID, OfficeID, DeletionFlag)
                VALUES (@EmployeeID, @OfficeID, 0);
                """
        };
        jobCommand.Parameters.Add("@EmployeeID", SqlDbType.Int).Value = employeeId;
        jobCommand.Parameters.Add("@OfficeID", SqlDbType.Int).Value = request.OfficeID;
        jobCommand.Parameters.Add("@LicenseNum", SqlDbType.VarChar, 11).Value =
            string.IsNullOrWhiteSpace(request.LicenseNum) ? DBNull.Value : request.LicenseNum.Trim();
        jobCommand.Parameters.Add("@Specialty", SqlDbType.VarChar, 30).Value =
            string.IsNullOrWhiteSpace(request.Specialty) ? DBNull.Value : request.Specialty;
        await jobCommand.ExecuteNonQueryAsync(cancellationToken);

        // 4. Doctor only: one schedule row per work day, all at the chosen office
        if (request.Role == "Doctor")
        {
            foreach (var day in request.WorkDays.Distinct())
            {
                using var dayCommand = connection.CreateCommand();
                dayCommand.Transaction = transaction;
                dayCommand.CommandText = """
                    INSERT INTO dbo.DoctorSchedule (DoctorID, OfficeID, DayOfWeek, DeletionFlag)
                    VALUES (@DoctorID, @OfficeID, @DayOfWeek, 0);
                    """;
                dayCommand.Parameters.Add("@DoctorID", SqlDbType.Int).Value = employeeId;
                dayCommand.Parameters.Add("@OfficeID", SqlDbType.Int).Value = request.OfficeID;
                dayCommand.Parameters.Add("@DayOfWeek", SqlDbType.Char, 3).Value = day;
                await dayCommand.ExecuteNonQueryAsync(cancellationToken);
            }
        }

        // 5. Login account: the role is the job just saved (the request only allows the three job roles)
        using var accountCommand = connection.CreateCommand();
        accountCommand.Transaction = transaction;
        accountCommand.CommandText = """
            INSERT INTO dbo.UserAccount
                (UserID, Username, PasswordHash, LastLogin, Role, IsActive, DeletionFlag)
            VALUES
                (@UserID, @Username, @PasswordHash, NULL, @Role, 1, 0);
            """;
        accountCommand.Parameters.Add("@UserID", SqlDbType.Int).Value = employeeId;
        accountCommand.Parameters.Add("@Username", SqlDbType.VarChar, 25).Value = request.Username;
        accountCommand.Parameters.Add("@PasswordHash", SqlDbType.VarChar, 60).Value = passwordHash;
        accountCommand.Parameters.Add("@Role", SqlDbType.VarChar, 12).Value = request.Role;
        await accountCommand.ExecuteNonQueryAsync(cancellationToken);

        // Only now are all the rows saved together
        await transaction.CommitAsync(cancellationToken);

        return employeeId;
    }
}