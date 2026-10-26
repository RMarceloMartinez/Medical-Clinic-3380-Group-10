using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/lookups")]
[Authorize(Roles = "Admin,Receptionist,Doctor")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class LookupsController : ControllerBase
{
    private readonly LookupService _lookupService;

    public LookupsController(LookupService lookupService)
    {
        _lookupService = lookupService;
    }

    [HttpGet("doctors")]
    public async Task<ActionResult<List<LookupItem>>> Doctors(CancellationToken cancellationToken)
    {
        return Ok(await _lookupService.GetDoctorsAsync(cancellationToken));
    }

    [HttpGet("patients")]
    public async Task<ActionResult<List<LookupItem>>> Patients(CancellationToken cancellationToken)
    {
        return Ok(await _lookupService.GetPatientsAsync(cancellationToken));
    }

    [HttpGet("offices")]
    public async Task<ActionResult<List<LookupItem>>> Offices(CancellationToken cancellationToken)
    {
        return Ok(await _lookupService.GetOfficesAsync(cancellationToken));
    }
}