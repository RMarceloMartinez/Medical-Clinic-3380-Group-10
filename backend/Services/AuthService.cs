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
}