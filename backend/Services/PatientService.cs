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

        using var patientCommand = connection.CreateCommand();
        patientCommand.Transaction = transaction;

        patientCommand.CommandText = """
            INSERT INTO dbo.Patient (PatientID, DeletionFlag)
            VALUES (@PatientID, 0);
            """;

        patientCommand.Parameters.Add("@PatientID", SqlDbType.Int)
            .Value = patientId;

        await patientCommand.ExecuteNonQueryAsync(cancellationToken);
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
}