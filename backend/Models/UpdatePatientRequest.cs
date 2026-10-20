using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class UpdatePatientRequest : IValidatableObject
{

    [Required, StringLength(15)]
    [RegularExpression(@"[^0-9]+")]
    public string FirstName { get; set; } = string.Empty;

    [StringLength(15)]
    [RegularExpression(@"[^0-9]+")]
    public string? MiddleName { get; set; }

    [Required, StringLength(31)]
    [RegularExpression(@"[^0-9]+")]
    public string LastName { get; set; } = string.Empty;

    [Required, StringLength(80)]
    public string StreetAddress { get; set; } = string.Empty;

    [StringLength(5)]
    public string? ApartmentNum { get; set; }

    [Required, StringLength(48)]
    public string City { get; set; } = string.Empty;

    [Required, StringLength(20)]
    public string State { get; set; } = string.Empty;

    [Required]
    [RegularExpression(@"[0-9]{5}",
        ErrorMessage = "ZIP code must contain five digits.")]
    public string ZipCode { get; set; } = string.Empty;

    [Required, StringLength(56)]
    public string Country { get; set; } = string.Empty;

    [Required]
    [RegularExpression(@"[0-9]{10}",
        ErrorMessage = "Phone must contain ten digits without punctuation.")]
    public string Phone { get; set; } = string.Empty;

    [Required]
    [RegularExpression(@"[MFI]",
        ErrorMessage = "Sex must be M, F, or I.")]
    public string Sex { get; set; } = string.Empty;

    [Required]
    public DateOnly? DateOfBirth { get; set; }

    [Required, StringLength(100), EmailAddress]
    [RegularExpression(@"[^@\s]+@[^@\s]+\.[^@\s]+",
        ErrorMessage = "Enter a valid email address without spaces.")]
    public string Email { get; set; } = string.Empty;

    public IEnumerable<ValidationResult> Validate(
        ValidationContext validationContext)
    {
        var today = DateOnly.FromDateTime(
            TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
                DateTime.UtcNow, "America/Chicago"));

        if (DateOfBirth.HasValue && DateOfBirth.Value > today)
        {
            yield return new ValidationResult(
                "Date of birth cannot be in the future.",
                new[] { nameof(DateOfBirth) });
        }
    }
}