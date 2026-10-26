using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/patients")]
[Authorize(Roles = "Admin,Receptionist")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class PatientsController : ControllerBase
{
    private readonly PatientService _patientService;

    public PatientsController(PatientService patientService)
    {
        _patientService = patientService;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<PatientResponse>> GetById(
        int id,
        CancellationToken cancellationToken)
    {
        if (id < 1000000 || id > 9999999)
        {
            return BadRequest(new
            {
                message = "Patient ID must be seven digits."
            });
        }

        var patient = await _patientService.GetByIdAsync(
            id, cancellationToken);

        if (patient is null)
        {
            return NotFound(new
            {
                message = "Patient not found."
            });
        }

        return Ok(patient);
    }
    [HttpPost]
    [Consumes("application/json")]
    public async Task<IActionResult> Create(
        [FromBody] CreatePatientRequest request,
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

        try
        {
            int patientId = await _patientService.CreateAsync(
                request, cancellationToken);

            return CreatedAtAction(
                nameof(GetById),
                new { id = patientId },
                new { patientID = patientId });
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)
        {
            return Conflict(new
            {
                message = "A member with that SSN or email already exists."
            });
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message = "The patient information violates a database rule. Check the submitted values."
            });
        }
    }
    [HttpPut("{id:int}")]
    [Consumes("application/json")]
    public async Task<IActionResult> Update(
        int id,
        [FromBody] UpdatePatientRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        if (id < 1000000 || id > 9999999)
        {
            return BadRequest(new
            {
                message = "Patient ID must be seven digits."
            });
        }

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
            bool updated = await _patientService.UpdateAsync(
                id, request, cancellationToken);

            if (!updated)
            {
                return NotFound(new
                {
                    message = "Patient not found."
                });
            }

            return NoContent();
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)
        {
            return Conflict(new
            {
                message = "A member with that email already exists."
            });
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return BadRequest(new
            {
                message = "The patient information violates a database rule. Check the submitted values."
            });
    }}

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Deactivate(
        int id,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
    {
        if (id < 1000000 || id > 9999999)
        {
            return BadRequest(new
            {
                message = "Patient ID must be seven digits."
            });
        }

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

        bool deactivated = await _patientService.DeactivateAsync(
            id, cancellationToken);

        if (!deactivated)
        {
            return NotFound(new
            {
                message = "Patient not found or already deactivated."
            });
        }

        return NoContent();
    }
}