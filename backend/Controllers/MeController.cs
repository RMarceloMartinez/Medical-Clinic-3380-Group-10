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
            Channel = "Web Portal",
            VisitReason = request.VisitReason
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


    [HttpGet("charges")]
    public async Task<IActionResult> MyCharges(
        [FromServices] PaymentService payments,
        CancellationToken cancellationToken)
    {
        return Ok(await payments.GetPatientChargesAsync(
            CurrentPatientId(), cancellationToken));
    }

    [HttpGet("payments")]
    public async Task<IActionResult> MyPaymentHistory(
        [FromServices] PaymentService payments,
        CancellationToken cancellationToken)
    {
        return Ok(await payments.GetPatientPaymentHistoryAsync(
            CurrentPatientId(), cancellationToken));
    }

    [HttpGet("payment-methods")]
    public async Task<IActionResult> MyPaymentMethods(
        [FromServices] PaymentService payments,
        CancellationToken cancellationToken)
    {
        return Ok(await payments.GetPaymentMethodsAsync(cancellationToken));
    }

    [HttpPost("payments")]
    [Consumes("application/json")]
    public async Task<IActionResult> PayMyVisit(
        [FromBody] CreateMyPaymentRequest request,
        [FromServices] PaymentService payments,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new { message = "Invalid or missing CSRF token." });
        }

        var centralNow = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
            DateTimeOffset.UtcNow, "America/Chicago");

        var payment = new CreatePaymentRequest
        {
            AppointmentID = request.AppointmentID,
            InstallmentNumber = 1, // Assigned under the transaction lock.
            PaymentDate = DateOnly.FromDateTime(centralNow.DateTime),
            PayStatus = "Completed",
            Details = new List<PaymentDetailRequest>
            {
                new()
                {
                    MethodID = request.MethodID,
                    AmountApplied = request.AmountApplied
                }
            }
        };

        try
        {
            int id = await payments.CreateAsync(
                payment, cancellationToken, CurrentPatientId());
            return Ok(new { paymentID = id, amount = request.AmountApplied });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Appointment was not found." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (SqlException ex) when (
            ex.Errors.Cast<SqlError>().Any(e => e.Number == 50003))
        {
            return Conflict(new
            {
                message = "This payment exceeds the remaining balance. Refresh and try again."
            });
        }
        catch (SqlException ex) when (
            ex.Errors.Cast<SqlError>().Any(e => e.Number == 50007))
        {
            return Conflict(new
            {
                message = "This cancelled visit has no cancellation fee to pay."
            });
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)
        {
            return Conflict(new
            {
                message = "Another payment was recorded. Refresh before trying again."
            });
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message = "The appointment or payment method is invalid."
            });
        }
    }

// GET /api/me/medical-records
    [HttpGet("medical-records")]
    public async Task<IActionResult> MyMedicalRecords(
        [FromServices] PatientMedicalRecordService medicalRecordService,
        CancellationToken cancellationToken)
    {
        var records = await medicalRecordService.GetRecordsAsync(
            CurrentPatientId(), cancellationToken);

        return Ok(records);
    }

    [HttpGet("chart-requests")]
    public async Task<IActionResult> MyChartRequests(
        [FromServices] ChartRequestService chartRequestService,
        CancellationToken cancellationToken)
    {
        var requests = await chartRequestService.GetRequestsAsync(
            CurrentPatientId(), cancellationToken);

        return Ok(requests);
    }

    [HttpPost("chart-requests")]
    public async Task<IActionResult> CreateChartRequest(
        [FromBody] CreateChartRequestDto request,
        [FromServices] ChartRequestService chartRequestService,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new { message = "Invalid or missing CSRF token." });
        }

        if (request.DoctorID <= 0)
            return BadRequest("Please select a valid doctor.");

        try
        {
            var requestId = await chartRequestService.CreateRequestAsync(
                CurrentPatientId(),
                request.DoctorID,
                cancellationToken);

            return Ok(new
            {
                requestID = requestId,
                status = "Pending",
                message = "Chart request submitted successfully."
            });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    public class CreateChartRequestDto
    {
        public int DoctorID { get; set; }
    }


}
