using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class CancelAppointmentRequest
{
    [Required]
    [StringLength(200)]
    public string CancelReason { get; set; } = string.Empty;

    [Required]
    [StringLength(7)]
    [RegularExpression("(Patient|Doctor|Staff)",
                        ErrorMessage = "CancelledBy must be Patient, Doctor, or Staff.")]
    public string CancelledBy {get; set; } = string.Empty;
}