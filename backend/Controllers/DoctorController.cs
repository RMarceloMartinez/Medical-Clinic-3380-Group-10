using System.Security.Claims;
using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Controllers;

// Only users with the Doctor role can reach anything in here.
[ApiController]
[Route("api/doctor")]
[Authorize(Roles = "Doctor")]
public class DoctorController : ControllerBase
{
    private const string NoVitalsMessage = "Vitals not recorded yet; the nurse records them first.";

    private readonly DoctorService _doctorService;

    public DoctorController(DoctorService doctorService)
    {
        _doctorService = doctorService;
    }

    // The doctor's ID comes from the login's "UserID" claim, never from the request.
    private int CurrentDoctorId => int.Parse(User.FindFirstValue("UserID")!);

    // GET api/doctor/visits?range=today   or   ?range=week
    [HttpGet("visits")]
    public async Task<ActionResult<List<DoctorVisitRow>>> GetVisits(
        [FromQuery] string range = "today",
        CancellationToken cancellationToken = default)
    {
        if (range is not ("today" or "week"))
        {
            return BadRequest(new { error = "range must be 'today' or 'week'." });
        }

        return await _doctorService.GetVisitsAsync(CurrentDoctorId, range, cancellationToken);
    }

    // GET api/doctor/appointments/1000005/record   (the nurse's vitals and any saved notes)
    [HttpGet("appointments/{appointmentId:int}/record")]
    public async Task<IActionResult> GetRecord(
        int appointmentId,
        CancellationToken cancellationToken)
    {
        var denied = await CheckOwnershipAsync(appointmentId, cancellationToken);
        if (denied is not null)
        {
            return denied;
        }

        var record = await _doctorService.GetRecordAsync(appointmentId, cancellationToken);

        if (record is null)
        {
            return NotFound(new { error = NoVitalsMessage });
        }

        return Ok(record);
    }

    // PUT api/doctor/appointments/1000005/notes
    [HttpPut("appointments/{appointmentId:int}/notes")]
    public async Task<IActionResult> SaveNotes(
        int appointmentId,
        [FromBody] SaveNotesRequest request,
        CancellationToken cancellationToken)
    {
        var denied = await CheckOwnershipAsync(appointmentId, cancellationToken);
        if (denied is not null)
        {
            return denied;
        }

        try
        {
            var saved = await _doctorService.SaveNotesAsync(
                CurrentDoctorId, appointmentId, request, cancellationToken);

            if (!saved)
            {
                return NotFound(new { error = NoVitalsMessage });
            }

            return Ok(new { appointmentId });
        }
        catch (SqlException ex) when (ex.Number >= 50000)
        {
            // Errors raised by the database's own rules (triggers) become a plain sentence
            return BadRequest(new { error = ex.Message });
        }
    }

    // POST api/doctor/appointments/1000005/prescriptions
    // If the medication matches one of the patient's allergies, the first try returns 409 with a
    // warning; the page shows it and sends again with ConfirmAllergy = true if the doctor still wants it.
    [HttpPost("appointments/{appointmentId:int}/prescriptions")]
    public async Task<IActionResult> AddPrescription(
        int appointmentId,
        [FromBody] CreatePrescriptionRequest request,
        CancellationToken cancellationToken)
    {
        var denied = await CheckOwnershipAsync(appointmentId, cancellationToken);
        if (denied is not null)
        {
            return denied;
        }

        var conflicts = await _doctorService.GetAllergyConflictsAsync(
            appointmentId, request.MedicationName, cancellationToken);

        if (conflicts.Count > 0 && !request.ConfirmAllergy)
        {
            return Conflict(new
            {
                message = $"Allergy warning: this patient is allergic to {string.Join(", ", conflicts)}. "
                        + $"Check before prescribing {request.MedicationName.Trim()}.",
                allergyWarning = true
            });
        }

        try
        {
            var prescriptionId = await _doctorService.AddPrescriptionAsync(
                CurrentDoctorId, appointmentId, request, cancellationToken);

            if (prescriptionId is null)
            {
                return NotFound(new { message = NoVitalsMessage });
            }

            return Ok(new { prescriptionID = prescriptionId });
        }
        catch (SqlException ex) when (ex.Number >= 50000)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // 404 if the visit does not exist, 403 if it belongs to another doctor, otherwise null.
    private async Task<IActionResult?> CheckOwnershipAsync(int appointmentId, CancellationToken cancellationToken)
    {
        var ownerId = await _doctorService.GetVisitDoctorIdAsync(appointmentId, cancellationToken);

        if (ownerId is null)
        {
            return NotFound(new { error = "That visit was not found." });
        }

        if (ownerId != CurrentDoctorId)
        {
            return StatusCode(StatusCodes.Status403Forbidden,
                new { error = "This visit belongs to another doctor." });
        }

        return null;
    }
}
