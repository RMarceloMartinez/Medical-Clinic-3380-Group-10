using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

// The admin's Staff page: list employees and add new workers (with their login)
[ApiController]
[Route("api/employees")]
[Authorize(Roles = "Admin")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class EmployeesController : ControllerBase
{
    private readonly EmployeeService _employeeService;

    public EmployeesController(EmployeeService employeeService)
    {
        _employeeService = employeeService;
    }

    // GET api/employees
    [HttpGet]
    public async Task<ActionResult<List<EmployeeRow>>> List(CancellationToken cancellationToken)
    {
        return Ok(await _employeeService.ListAsync(cancellationToken));
    }

    // GET api/employees/specialties   (the doctor's specialty dropdown)
    [HttpGet("specialties")]
    public async Task<ActionResult<List<SpecialtyOption>>> Specialties(CancellationToken cancellationToken)
    {
        return Ok(await _employeeService.GetSpecialtiesAsync(cancellationToken));
    }

    // POST api/employees
    [HttpPost]
    [Consumes("application/json")]
    public async Task<IActionResult> Create(
        [FromBody] CreateEmployeeRequest request,
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

        try
        {
            int employeeId = await _employeeService.CreateAsync(request, cancellationToken);

            return Created($"/api/employees/{employeeId}", new { employeeID = employeeId });
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)   // a UNIQUE rule failed
        {
            string message =
                ex.Message.Contains("UQ_UserAccount_Username")
                    ? "That username is already taken."
                : ex.Message.Contains("UQ_Member_Email")
                    ? "Someone with that email is already registered."
                : ex.Message.Contains("UX_Member_SSN")
                    ? "That SSN is already registered."
                : ex.Message.Contains("UQ_Doctor_LicenseNum") || ex.Message.Contains("UQ_Nurse_LicenseNum")
                    ? "That license number is already registered."
                : "Some of these details are already registered.";

            return Conflict(new { message });
        }
        catch (SqlException ex) when (ex.Number == 547)            // a CHECK or FOREIGN KEY rule failed
        {
            string message =
                ex.Message.Contains("FK_Doctor_Specialty")
                    ? "Choose a specialty from the list."
                : ex.Message.Contains("Office")
                    ? "Choose an office from the list."
                : "Some details are not valid. Check the form and try again.";

            return BadRequest(new { message });
        }
    }
}