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
}