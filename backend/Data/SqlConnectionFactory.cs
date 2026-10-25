using Microsoft.Data.SqlClient;

namespace ClinicApi.Data;

public class SqlConnectionFactory
{
    private readonly IConfiguration _configuration;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public SqlConnection CreateConnection()
    {
        string? connectionString =
            _configuration.GetConnectionString("ClinicDb");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "The ClinicDb connection string is not configured.");
        }

        return new SqlConnection(connectionString);
    }
}