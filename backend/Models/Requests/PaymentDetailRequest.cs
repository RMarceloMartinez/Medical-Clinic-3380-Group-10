using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class PaymentDetailRequest : IValidatableObject
{
    [Range(1, int.MaxValue)]
    public int MethodID { get; set; }

    [Range(typeof(decimal), "0.01", "99999999.99")]
    public decimal AmountApplied { get; set; }

    public IEnumerable<ValidationResult> Validate(
        ValidationContext validationContext)
    {
        if (decimal.Round(AmountApplied, 2) != AmountApplied)
        {
            yield return new ValidationResult(
                "Amount must have no more than two decimal places.",
                new[] { nameof(AmountApplied) });
        }
    }
}