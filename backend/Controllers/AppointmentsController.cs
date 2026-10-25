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

    [HttpGet]
    public async Task<ActionResult<List<AppointmentResponse>>> List(
        [FromQuery] int? doctorId,
        [FromQuery] int? patientId,
        [FromQuery] int? officeId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] string? status,
        CancellationToken cancellationToken

    )
    {
        if(from.HasValue && to.HasValue && from.Value > to.Value)
        {
            return BadRequest(new
            {
                message = "The start date must be on or before the end date."
            });
        }
        if(status is not null && status is not("Scheduled" or "Completed" or "Cancelled"))
        {
            return BadRequest(new
            {
                message = "Status must be Scheduled, Completed, or Cancelled."
            });
        }

        var appointments = await _appointmentService.ListAsync(
            doctorId, patientId, officeId, from, to, status, cancellationToken
        );

        return Ok(appointments);
    }

    [HttpGet("{id:int}")]

    public async Task<ActionResult<AppointmentResponse>> GetById(
        int id,
        CancellationToken cancellationToken)
    {
        if (id < 1000000 || id > 9999999)
        {
            return BadRequest(new
            {
                message = "Appointment ID must be seven digits."
            });
        }

        var appointment = await _appointmentService.GetByIdAsync(
            id, cancellationToken);

        if (appointment is null)
        {
            return NotFound(new
            {
                message = "Appointment not found."
            });
        }

        return Ok(appointment);
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
