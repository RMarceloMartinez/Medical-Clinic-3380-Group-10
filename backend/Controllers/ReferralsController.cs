using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/referrals")]
[Authorize(Roles = "Doctor")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]

public class ReferralsController : ControllerBase
{
    private readonly ReferralService _referralService;

    public ReferralsController(ReferralService referralService)
    {
        _referralService = referralService;
    }

    private int? CurrentDoctorId =>
        int.TryParse(User.FindFirst("UserID")?.Value, out int id) ? id : null;

    [HttpGet]
    public async Task<ActionResult<List<ReferralRow>>> Sent(CancellationToken cancellationToken)
    {
        if(CurrentDoctorId is not int doctorId){return Forbid();}
        return Ok(await _referralService.GetSentAsync(doctorId, cancellationToken));
    }

    [HttpGet("patients")]
    public async Task<ActionResult<List<LookupItem>>> MyPatients(CancellationToken cancellationToken)
    {
        if(CurrentDoctorId is not int doctorId){return Forbid();}
        return Ok(await _referralService.GetMyPatientsAsync(doctorId, cancellationToken));
    }
    
    [HttpGet("specialists")]
    public async Task<ActionResult<List<LookupItem>>> Specialists(CancellationToken cancellationToken)
    {
        return Ok(await _referralService.GetSpecialistsAsync(cancellationToken));

    }

    [HttpPost]
    [Consumes("application/json")]
    public async Task<IActionResult>Create(
        [FromBody] CreateReferralRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
       try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new
            {
                message = "Invalid request verification token."
            });
        }
        if(CurrentDoctorId is not int doctorId){return Forbid();}

        try
        {
            int referralId = await _referralService.CreateAsync(doctorId,request,cancellationToken);
            return Created($"/api/referrals/{referralId}", new{referralID = referralId});
        }
        catch(SqlException ex) when (ex.Errors.Cast<SqlError>().Any(e => e.Number == 50004))
        {
            return BadRequest(new
            {
                message = "You can only refer patients you are the primary doctor for."
            });
        }
        catch(SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message = "That patient or specialist doesn't exist, or you picked yourself."
            });
        }
    }
}