using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize(Roles = "Admin,Receptionist")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class PaymentsController : ControllerBase
{
    private readonly PaymentService _paymentService;

    public PaymentsController(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(
        int id,
        CancellationToken cancellationToken)
    {
        if (id < 1000000 || id > 9999999)
            return BadRequest(new
            {
                message = "Payment ID must be seven digits."
            });

        var payment = await _paymentService.GetByIdAsync(
            id, cancellationToken);

        if (payment is null)
            return NotFound(new
            {
                message = "Payment was not found."
            });

        return Ok(payment);
    }

    [HttpPost]
    [Consumes("application/json")]
    public async Task<IActionResult> Create(
        [FromBody] CreatePaymentRequest request,
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
                message = "Invalid or missing CSRF token."
            });
        }

        try
        {
            var paymentId = await _paymentService.CreateAsync(
                request, cancellationToken);

            return CreatedAtAction(
                nameof(GetById),
                new { id = paymentId },
                new { paymentID = paymentId });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new
            {
                message = "Appointment was not found."
            });
        }
        catch (SqlException ex) when (
            ex.Errors.Cast<SqlError>().Any(
                error => error.Number == 50003))
        {
            return Conflict(new
            {
                message =
                    "Completed payments cannot exceed the appointment total cost."
            });
        }
        catch (SqlException ex) when (
            ex.Number is 2601 or 2627)
        {
            return Conflict(new
            {
                message =
                    "That installment number already exists for this appointment."
            });
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message =
                    "The appointment, payment method, or payment values are invalid."
            });
        }
    }
}