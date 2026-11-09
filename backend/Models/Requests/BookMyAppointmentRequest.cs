using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// What a patient sends to book; the server fills in everything else
public class BookMyAppointmentRequest : IValidatableObject
{
    [Range(1000000, 9999999)]
    public int DoctorID { get; set; }

    [Range(1000000, 9999999)]
    public int OfficeID { get; set; }

    [Required]
    public DateTime? AppointmentDateTime { get; set; }

    [Required(ErrorMessage = "Tell us the reason for your visit.")]
    [StringLength(200, ErrorMessage = "Keep the reason for the visit under 200 characters.")]
    public string? VisitReason { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        var now = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
            DateTime.UtcNow, "America/Chicago");

        if (AppointmentDateTime.HasValue && AppointmentDateTime.Value < now)
        {
            yield return new ValidationResult(
                "Appointment cannot be in the past.",
                new[] { nameof(AppointmentDateTime) });
        }
    }
}