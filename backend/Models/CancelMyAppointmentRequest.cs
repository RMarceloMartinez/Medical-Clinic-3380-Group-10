using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// A patient only gives a reason; CancelledBy is always 'Patient'
public class CancelMyAppointmentRequest
{
    [Required]
    [StringLength(200)]
    public string CancelReason { get; set; } = string.Empty;
}