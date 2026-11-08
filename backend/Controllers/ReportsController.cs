using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/reports")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class ReportsController : ControllerBase
{
    private readonly ReportService _reportService;

    public ReportsController(ReportService reportService)
    {
        _reportService = reportService;
    }

    [HttpGet("revenue")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<OfficeRevenueRow>>> Offices(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        CancellationToken cancellationToken)
    {
        if (from > to)
        {
            return BadRequest(new
            {
                message = "From date must be on or before To date."
            });
        }

        return Ok(await _reportService.GetOfficeRevenueAsync(
            from, to, cancellationToken));
    }

    [HttpGet("activity")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<AppointmentActivityRow>>> Activity(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        CancellationToken cancellationToken)
    {
        if (from > to)
        {
            return BadRequest(new
            {
                message = "From date must be on or before To date."
            });
        }

        return Ok(await _reportService.GetAppointmentActivityAsync(
            from, to, cancellationToken));
    }

    [HttpGet("health-summary")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<PatientHealthSummaryRow>>> HealthSummary(
        [FromQuery] int patientId,
        CancellationToken cancellationToken)
    {
        if (patientId < 1000000 || patientId > 9999999)
        {
            return BadRequest(new
            {
                message = "Patient ID must be seven digits."
            });
        }

        return Ok(await _reportService.GetPatientHealthSummaryAsync(
            patientId, cancellationToken));
    }

    [HttpGet("health-trends")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> HealthTrends(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        CancellationToken cancellationToken)
    {
        if (from == default || to == default || from > to)
        {
            return BadRequest(new
            {
                message = "Please provide a valid date range."
            });
        }

        var results = await _reportService.GetHealthTrendsAsync(
            from, to, cancellationToken);

        return Ok(results);
    }

    // R3: GET /api/reports/visits?from=&to=  or  ?patientId=
    [HttpGet("visits")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<VisitDetailRow>>> Visits(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int? patientId,
        CancellationToken cancellationToken)
    {
        if (patientId is null && (from is null || to is null))
        {
            return BadRequest(new
            {
                message = "Pick a patient or both dates."
            });
        }

        if (from > to)
        {
            return BadRequest(new
            {
                message = "From date must be on or before To date."
            });
        }

        return Ok(await _reportService.GetVisitDetailsAsync(
            from, to, patientId, cancellationToken));
    }
}
