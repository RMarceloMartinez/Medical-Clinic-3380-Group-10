using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/appointments")]
[Authorize(Roles ="Admin,Receptionist")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]

public class AppointmentsController : ControllerBase
{
    private readonly AppointmentService _appointmentService;

    public AppointmentsController(AppointmentService appointmentService)
    {
        _appointmentService = appointmentService;
    }
    [HttpPost]
    [Consumes("application/json")]
    public async Task<IActionResult> Create(
        [FromBody] CreateAppointmentRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken
    )
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

        try
        {
            int appointmentId = await _appointmentService.CreateAsync(request, cancellationToken);
            return Created($"/api/appointments/{appointmentId}", new{appointmentID = appointmentId});
        }

        catch(SqlException ex) when (ex.Errors.Cast<SqlError>().Any(e => e.Number >= 50000))
        {
            var triggerError = ex.Errors.Cast<SqlError>().First(e => e.Number >= 50000);
            return BadRequest(new 
            {
                message = triggerError.Message
            });
        }
        catch(SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message = "The patient, doctor, office, or referral doesn't exist."
            });
        }
    }
}
