using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ClinicApi.Models;

public class RegisterPatientRequest : IValidatableObject
{
    // --- Member fields (same rules as CreatePatientRequest) ---

    [Required]
    [RegularExpression(@"[0-9]{3}-[0-9]{2}-[0-9]{4}",
        ErrorMessage = "SSN must use the format 123-45-6789.")]
    public string SSN { get; set; } = string.Empty;

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

    // --- Account fields (UserAccount) ---

    [Required, StringLength(25, MinimumLength = 4)]
    [RegularExpression(@"[A-Za-z0-9._-]+",
        ErrorMessage = "Username can use letters, numbers, dots, dashes and underscores only.")]
    public string Username { get; set; } = string.Empty;

    [Required, StringLength(72, MinimumLength = 8,
        ErrorMessage = "Password must be 8 to 72 characters long.")]
    public string Password { get; set; } = string.Empty;

    // --- Care relationship (PatientDoctor, RolePlayed = 'Primary') ---

    [Range(1000000, 9999999,
        ErrorMessage = "Pick a primary care doctor.")]
    public int PrimaryDoctorID { get; set; }

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

        // bcrypt only uses the first 72 bytes, and login rejects longer passwords
        if (Encoding.UTF8.GetByteCount(Password) > 72)
        {
            yield return new ValidationResult(
                "Password is too long.",
                new[] { nameof(Password) });
        }
    }
}