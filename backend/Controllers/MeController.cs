using System.Security.Claims;
using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

// The patient portal. Every action works on the logged-in patient only:
// the patient ID comes from the login cookie, never from the URL or the form.
[ApiController]
[Route("api/me")]
[Authorize(Roles = "Patient")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class MeController : ControllerBase
{
    private readonly AppointmentService _appointmentService;
    private readonly QueryService _queryService;

    public MeController(AppointmentService appointmentService, QueryService queryService)
    {
        _appointmentService = appointmentService;
        _queryService = queryService;
    }

    // The "UserID" claim was stored at login (AuthController.Login)
    private int CurrentPatientId()
    {
        return int.Parse(User.FindFirstValue("UserID")!);
    }

    [HttpGet("appointments")]                             // GET /api/me/appointments
    public async Task<ActionResult<List<AppointmentResponse>>> MyAppointments(
        CancellationToken cancellationToken)
    {
        var appointments = await _appointmentService.ListAsync(
            null, CurrentPatientId(), null, null, null, null, cancellationToken);

        return Ok(appointments);
    }

    [HttpGet("doctors")]                                  // GET /api/me/doctors
    public async Task<ActionResult<List<BookableDoctorRow>>> MyDoctors(
        CancellationToken cancellationToken)
    {
        return Ok(await _appointmentService.GetBookableDoctorsAsync(
            CurrentPatientId(), cancellationToken));
    }

    [HttpGet("balance")]                                  // GET /api/me/balance
    public async Task<ActionResult<PatientBalanceRow>> MyBalance(
        CancellationToken cancellationToken)
    {
        var balance = await _queryService.GetPatientBalanceAsync(
            CurrentPatientId(), cancellationToken);

        return Ok(balance ?? new PatientBalanceRow());     // no visits yet = all zeros
    }

    [HttpPost("appointments")]                            // POST /api/me/appointments
    [Consumes("application/json")]
    public async Task<IActionResult> Book(
        [FromBody] BookMyAppointmentRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new { message = "Invalid request verification token." });
        }

        int patientId = CurrentPatientId();

        // The doctor + office must be one of this patient's bookable choices
        var choices = await _appointmentService.GetBookableDoctorsAsync(
            patientId, cancellationToken);

        var choice = choices.FirstOrDefault(c =>
            c.DoctorID == request.DoctorID && c.OfficeID == request.OfficeID);

        if (choice is null)
        {
            return BadRequest(new
            {
                message = "You can book your primary doctor, or a specialist you have a referral to, at an office where they work."
            });
        }

        // The server decides everything the patient must not choose
        var create = new CreateAppointmentRequest
        {
            PatientID = patientId,
            DoctorID = choice.DoctorID,
            OfficeID = choice.OfficeID,
            ReferralID = choice.ReferralID,
            AppointmentDateTime = request.AppointmentDateTime,
            TotalCost = choice.VisitFee,
            Channel = "Web Portal"
        };

        try
        {
            int appointmentId = await _appointmentService.CreateAsync(create, cancellationToken);
            var appointment = await _appointmentService.GetByIdAsync(appointmentId, cancellationToken);

            return Created($"/api/me/appointments/{appointmentId}", appointment);
        }
        catch (SqlException ex) when (ex.Errors.Cast<SqlError>().Any(e => e.Number >= 50000))
        {
            var triggerError = ex.Errors.Cast<SqlError>().First(e => e.Number >= 50000);
            return BadRequest(new { message = triggerError.Message });   // e.g. doctor not working that day
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new { message = "That appointment could not be booked." });
        }
    }

    [HttpPost("appointments/{id:int}/cancel")]           // POST /api/me/appointments/1000010/cancel
    [Consumes("application/json")]
    public async Task<IActionResult> Cancel(
        int id,
        [FromBody] CancelMyAppointmentRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new { message = "Invalid request verification token." });
        }

        var appointment = await _appointmentService.GetByIdAsync(id, cancellationToken);

        // Someone else's appointment looks the same as a missing one
        if (appointment is null || appointment.PatientID != CurrentPatientId())
        {
            return NotFound(new { message = "Appointment not found." });
        }

        if (appointment.AppointStatus != "Scheduled")
        {
            return BadRequest(new { message = "Only scheduled appointments can be cancelled." });
        }

        try
        {
            await _appointmentService.CancelAsync(
                id,
                new CancelAppointmentRequest
                {
                    CancelReason = request.CancelReason,
                    CancelledBy = "Patient"
                },
                cancellationToken);

            return Ok(await _appointmentService.GetByIdAsync(id, cancellationToken));
        }
        catch (SqlException ex) when (ex.Errors.Cast<SqlError>().Any(e => e.Number >= 50000))
        {
            var triggerError = ex.Errors.Cast<SqlError>().First(e => e.Number >= 50000);
            return BadRequest(new { message = triggerError.Message });
        }
    }
}