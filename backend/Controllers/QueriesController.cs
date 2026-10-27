using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/queries")]
[Authorize]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class QueriesController : ControllerBase
{
    private readonly QueryService _queryService;

    public QueriesController(QueryService queryService)
    {
        _queryService = queryService;
    }

    [HttpGet("patients")]
    [Authorize(Roles = "Admin,Receptionist,Doctor")]
    public async Task<ActionResult<List<PatientSearchRow>>> SearchPatients([FromQuery] string? name,
                                                                          [FromQuery] DateOnly? dateOfBirth,
                                                                          CancellationToken cancellationToken)
    {
        return Ok(await _queryService.SearchPatientsAsync(name, dateOfBirth, cancellationToken));
    }

        // Q2: GET /api/queries/balance?patientId=1000002
    [HttpGet("balance")]
    [Authorize(Roles = "Admin,Receptionist")]
    public async Task<ActionResult<PatientBalanceRow>> PatientBalance([FromQuery] int patientId,
                                                                      CancellationToken cancellationToken)
    {
        if (patientId < 1000000 || patientId > 9999999)
        {
            return BadRequest(new
            {
                message = "Patient ID must be seven digits."
            });
        }

        var balance = await _queryService.GetPatientBalanceAsync(patientId, cancellationToken);

        if (balance is null)
        {
            return NotFound(new
            {
                message = "No balance found for that patient."
            });
        }

        return Ok(balance);
    }
}