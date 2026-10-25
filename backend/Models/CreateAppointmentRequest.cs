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

    [Range(0, 99999999.99)]
    public decimal TotalCost { get; set; }

    [Required]
    [StringLength(10)]
    [RegularExpression ("(Phone|Web Portal)", ErrorMessage = "Appointment must be done by Phone Call or the Web Portal")]
    public string Channel { get; set; } = string.Empty;

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