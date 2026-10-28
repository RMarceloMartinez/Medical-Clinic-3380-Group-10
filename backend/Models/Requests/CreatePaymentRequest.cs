using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class CreatePaymentRequest : IValidatableObject
{
    [Range(1000000, 9999999)]
    public int AppointmentID { get; set; }

    [Range(1, int.MaxValue)]
    public int InstallmentNumber { get; set; }

    [Required]
    public DateOnly? PaymentDate { get; set; }

    [Required]
    [RegularExpression("^(Pending|Completed)$",
        ErrorMessage = "Status must be Pending or Completed.")]
    public string PayStatus { get; set; } = "Completed";

    [Required]
    [MinLength(1)]
    public List<PaymentDetailRequest> Details { get; set; } = new();

    public IEnumerable<ValidationResult> Validate(
        ValidationContext validationContext)
    {
        if (Details is null)
            yield break;

        var methodIds = new HashSet<int>();

        foreach (var detail in Details)
        {
            if (detail is null)
            {
                yield return new ValidationResult(
                    "Payment details cannot contain null entries.",
                    new[] { nameof(Details) });

                continue;
            }

            if (!methodIds.Add(detail.MethodID))
            {
                yield return new ValidationResult(
                    "Each payment method can appear only once.",
                    new[] { nameof(Details) });
            }
        }
    }
}