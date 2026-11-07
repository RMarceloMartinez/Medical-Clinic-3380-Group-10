using System.Security.Claims;
using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ClinicApi.Controllers;

// Only users with the Nurse role can reach anything in here.
[ApiController]
[Route("api/nurse")]
[Authorize(Roles = "Nurse")]
public class NurseController : ControllerBase
{
    private readonly NurseService _nurseService;

    public NurseController(NurseService nurseService)
    {
        _nurseService = nurseService;
    }

    // The nurse's ID comes from the login cookie, never from the request.
    // ASSUMPTION: the NameIdentifier claim holds the user's MemberID. Copy however your other
    // controllers read the current user (e.g. the doctor's ID for Complete) if it differs.
    private int CurrentNurseId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // GET api/nurse/visits?range=today   or   ?range=week
    [HttpGet("visits")]
    public async Task<ActionResult<List<NurseVisitRow>>> GetVisits(
        [FromQuery] string range = "today",
        CancellationToken cancellationToken = default)
    {
        if (range is not ("today" or "week"))
        {
            return BadRequest(new { error = "range must be 'today' or 'week'." });
        }

        return await _nurseService.GetVisitsAsync(CurrentNurseId, range, cancellationToken);
    }

    // POST api/nurse/appointments/1000005/vitals
    [HttpPost("appointments/{appointmentId:int}/vitals")]
    public async Task<IActionResult> RecordVitals(
        int appointmentId,
        [FromBody] RecordVitalsRequest request,
        CancellationToken cancellationToken)
    {
        if (request.SystolicBP <= request.DiastolicBP)
        {
            return BadRequest(new { error = "Systolic pressure must be higher than diastolic." });
        }

        var recordId = await _nurseService.RecordVitalsAsync(
            CurrentNurseId, appointmentId, request, cancellationToken);

        if (recordId is null)
        {
            return Conflict(new
            {
                error = "Vitals were not saved. The visit may not be at your office, may no longer be scheduled, or may already have vitals."
            });
        }

        return Ok(new { recordId });
    }

    // GET api/nurse/appointments/1000005/vitals   (the saved vitals, to fill in the edit screen)
    [HttpGet("appointments/{appointmentId:int}/vitals")]
    public async Task<IActionResult> GetVitals(
        int appointmentId,
        CancellationToken cancellationToken)
    {
        var vitals = await _nurseService.GetVitalsAsync(CurrentNurseId, appointmentId, cancellationToken);

        if (vitals is null)
        {
            return NotFound(new { error = "No saved vitals were found for this visit at your office." });
        }

        return Ok(vitals);
    }

    // PUT api/nurse/appointments/1000005/vitals   (replace the saved vitals)
    [HttpPut("appointments/{appointmentId:int}/vitals")]
    public async Task<IActionResult> UpdateVitals(
        int appointmentId,
        [FromBody] RecordVitalsRequest request,
        CancellationToken cancellationToken)
    {
        if (request.SystolicBP <= request.DiastolicBP)
        {
            return BadRequest(new { error = "Systolic pressure must be higher than diastolic." });
        }

        var updated = await _nurseService.UpdateVitalsAsync(
            CurrentNurseId, appointmentId, request, cancellationToken);

        if (!updated)
        {
            return Conflict(new
            {
                error = "Vitals were not changed. The visit may not be at your office, may no longer be scheduled, or may not have vitals yet."
            });
        }

        return Ok(new { appointmentId });
    }

    // GET api/nurse/patients/1000010/chart
    [HttpGet("patients/{patientId:int}/chart")]
    public async Task<IActionResult> GetPatientChart(
        int patientId,
        CancellationToken cancellationToken)
    {
        var chart = await _nurseService.GetPatientChartAsync(CurrentNurseId, patientId, cancellationToken);

        if (chart is null)
        {
            return StatusCode(StatusCodes.Status403Forbidden,
                new { error = "This patient has no appointments at your office." });
        }

        return Ok(chart);
    }
}
