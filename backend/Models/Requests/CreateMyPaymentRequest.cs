using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// Reuses the staff payment amount and decimal-place validation.
public class CreateMyPaymentRequest : PaymentDetailRequest
{
    [Range(1000000, 9999999)]
    public int AppointmentID { get; set; }
}
