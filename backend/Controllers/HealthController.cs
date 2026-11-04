using ClinicApi.Models;
using ClinicApi.Services;
using ClinicApi.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/health")]
[AllowAnonymous]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class HealthController : ControllerBase
{
    private readonly SqlConnectionFactory _sqlConnectionFactory;

    public HealthController(SqlConnectionFactory sqlConnectionFactory)
    {
        _sqlConnectionFactory = sqlConnectionFactory;
    }

[HttpGet]

public async Task<IActionResult> Check(CancellationToken cancellationToken)
    {
        try
        {
            using var connection = _sqlConnectionFactory.CreateConnection();

            await connection.OpenAsync(cancellationToken);

            using var command = connection.CreateCommand();
            command.CommandText = "SELECT 1;";
            await command.ExecuteScalarAsync(cancellationToken);

            return Ok(new { status = "ok" });
        }
        catch (SqlException)
        {
            return StatusCode(503, new { status = "waking" });
        }
    }
}