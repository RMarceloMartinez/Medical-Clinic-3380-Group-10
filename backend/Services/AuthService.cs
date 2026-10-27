using System.Data;
using System.Text;
using ClinicApi.Data;
using ClinicApi.Models;

namespace ClinicApi.Services;

public class AuthService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public AuthService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<LoginResponse?> ValidateLoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Username) ||
            request.Username.Length > 25 ||
            string.IsNullOrEmpty(request.Password) ||
            Encoding.UTF8.GetByteCount(request.Password) > 72)
        {
            return null;
        }

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT ua.AccountID, ua.UserID, ua.Username,
                   ua.PasswordHash, ua.Role, ua.IsActive
            FROM dbo.UserAccount AS ua
            INNER JOIN dbo.Member AS m
                ON m.MemberID = ua.UserID
            WHERE ua.Username = @Username
              AND ua.IsActive = 1
              AND ua.DeletionFlag = 0
              AND m.DeletionFlag = 0
              AND (
                  ua.Role <> 'Patient'
                  OR EXISTS (
                      SELECT 1
                      FROM dbo.Patient AS p
                      WHERE p.PatientID = ua.UserID
                        AND p.DeletionFlag = 0
                  )
              );
            """;

        command.Parameters.Add("@Username", SqlDbType.VarChar, 25)
            .Value = request.Username;

        using var reader =
            await command.ExecuteReaderAsync(cancellationToken);

        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        if (!reader.GetBoolean(reader.GetOrdinal("IsActive")))
        {
            return null;
        }

        string passwordHash =
            reader.GetString(reader.GetOrdinal("PasswordHash"));

        if (!BCrypt.Net.BCrypt.Verify(request.Password, passwordHash))
        {
            return null;
        }

        return new LoginResponse
        {
            AccountID = reader.GetInt32(reader.GetOrdinal("AccountID")),
            UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
            Username = reader.GetString(reader.GetOrdinal("Username")),
            Role = reader.GetString(reader.GetOrdinal("Role"))
        };
    }
    
    // Sign-up: Member -> Patient -> PatientDoctor (Primary) -> UserAccount,
    // all in one transaction so a failure leaves no half-made account.
    public async Task<int> RegisterPatientAsync(
        RegisterPatientRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.DateOfBirth is null)
        {
            throw new ArgumentException("Date of birth is required.");
        }

        // Same bcrypt work factor as the seed accounts (11)
        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password, 11);

        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var transaction = connection.BeginTransaction();

        // 1. The chosen doctor must be an active primary care doctor
        using var doctorCommand = connection.CreateCommand();
        doctorCommand.Transaction = transaction;

        doctorCommand.CommandText = """
            SELECT COUNT(*)
            FROM dbo.Doctor AS d
            JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
            WHERE d.DoctorID = @DoctorID
              AND d.Specialty IN ('Family Medicine', 'Internal Medicine', 'Pediatrics')
              AND d.DeletionFlag = 0
              AND m.DeletionFlag = 0;
            """;

        doctorCommand.Parameters.Add("@DoctorID", SqlDbType.Int)
            .Value = request.PrimaryDoctorID;

        if (await doctorCommand.ExecuteScalarAsync(cancellationToken) is not int doctorCount
            || doctorCount == 0)
        {
            throw new ArgumentException("Pick a primary care doctor from the list.");
        }

        // 2. Member row (same as PatientService.CreateAsync)
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
            .Value = request.SSN;

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

        // 3. Patient row (same ID as the member)
        using var patientCommand = connection.CreateCommand();
        patientCommand.Transaction = transaction;

        patientCommand.CommandText = """
            INSERT INTO dbo.Patient (PatientID, DeletionFlag)
            VALUES (@PatientID, 0);
            """;

        patientCommand.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        await patientCommand.ExecuteNonQueryAsync(cancellationToken);

        // 4. Primary doctor relationship (trigger 50006 needs it for every booking)
        using var careCommand = connection.CreateCommand();
        careCommand.Transaction = transaction;

        careCommand.CommandText = """
            INSERT INTO dbo.PatientDoctor
                (PatientID, DoctorID, RolePlayed, StartDate, DeletionFlag)
            VALUES
                (@PatientID, @DoctorID, 'Primary', CAST(GETDATE() AS DATE), 0);
            """;

        careCommand.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        careCommand.Parameters.Add("@DoctorID", SqlDbType.Int)
            .Value = request.PrimaryDoctorID;

        await careCommand.ExecuteNonQueryAsync(cancellationToken);

        // 5. Login account (role decided by the server, never by the form)
        using var accountCommand = connection.CreateCommand();
        accountCommand.Transaction = transaction;

        accountCommand.CommandText = """
            INSERT INTO dbo.UserAccount
                (UserID, Username, PasswordHash, LastLogin, Role, IsActive, DeletionFlag)
            VALUES
                (@UserID, @Username, @PasswordHash, NULL, 'Patient', 1, 0);
            """;

        accountCommand.Parameters.Add("@UserID", SqlDbType.Int)
            .Value = patientId;

        accountCommand.Parameters.Add("@Username", SqlDbType.VarChar, 25)
            .Value = request.Username;

        accountCommand.Parameters.Add("@PasswordHash", SqlDbType.VarChar, 60)
            .Value = passwordHash;

        await accountCommand.ExecuteNonQueryAsync(cancellationToken);

        // Only now are all four rows saved together
        await transaction.CommitAsync(cancellationToken);

        return patientId;
    }
}