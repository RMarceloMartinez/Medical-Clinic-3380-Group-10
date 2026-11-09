using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class CreateAppointmentRequest : IValidatableObject
{
    [Range(1000000,9999999)]
    public int PatientID { get; set; }

    [Range(1000000,9999999)]
    public int DoctorID { get; set; }

    [Range(1000000,9999999)]
    public int OfficeID { get; set; }

    [Range(1000000,9999999)]
    public int? ReferralID { get; set; }
    
    [Required]
    public DateTime? AppointmentDateTime { get; set; }

    [Required]
    [StringLength(10)]
    [RegularExpression ("(Phone|Web Portal)", ErrorMessage = "Appointment must be done by Phone Call or the Web Portal")]
    public string Channel { get; set; } = string.Empty;

    // Why the patient is coming in (optional, matches Appointment.VisitReason)
    [StringLength(200, ErrorMessage = "Keep the reason for the visit under 200 characters.")]
    public string? VisitReason { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        var now = TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
            DateTime.UtcNow, "America/Chicago"
        );
        
        if(AppointmentDateTime.HasValue && AppointmentDateTime.Value < now){
            yield return new ValidationResult(
                "Appointment cannot be in the past.",
                new[] {nameof(AppointmentDateTime)}
            );
        }
    }
}