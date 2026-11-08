using System.ComponentModel.DataAnnotations;
using System.Text;

namespace ClinicApi.Models;

// What the admin's "Add worker" form sends: the person, their login, and their job
public class CreateEmployeeRequest : IValidatableObject
{
    // --- Member fields (same rules as RegisterPatientRequest, but SSN is required) ---

    [Required(ErrorMessage = "SSN is required for employees.")]
    [RegularExpression(@"[0-9]{3}-[0-9]{2}-[0-9]{4}",
        ErrorMessage = "SSN must use the format 123-45-6789.")]
    public string? SSN { get; set; }

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

    // --- Job fields ---

    [Required]
    [RegularExpression("Doctor|Nurse|Receptionist",
        ErrorMessage = "Choose Doctor, Nurse or Receptionist.")]
    public string Role { get; set; } = string.Empty;

    // Every role works at one office
    [Range(1000000, 9999999, ErrorMessage = "Choose an office.")]
    public int OfficeID { get; set; }

    // Doctor (up to 11 characters) and nurse (up to 10)
    [StringLength(11)]
    public string? LicenseNum { get; set; }

    // Doctor only: must match a row in the Specialty table
    [StringLength(30)]
    public string? Specialty { get; set; }

    // Doctor only: "Mon", "Tue", ... at the office above
    public List<string> WorkDays { get; set; } = new();

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

        if (Role is "Doctor" or "Nurse" && string.IsNullOrWhiteSpace(LicenseNum))
        {
            yield return new ValidationResult("Enter the license number.", new[] { nameof(LicenseNum) });
        }

        if (Role == "Nurse" && LicenseNum?.Length > 10)
        {
            yield return new ValidationResult("A nurse license number has at most 10 characters.", new[] { nameof(LicenseNum) });
        }

        if (Role == "Doctor" && string.IsNullOrWhiteSpace(Specialty))
        {
            yield return new ValidationResult("Choose a specialty.", new[] { nameof(Specialty) });
        }

        if (Role == "Doctor" && WorkDays.Count == 0)
        {
            yield return new ValidationResult("Pick at least one work day.", new[] { nameof(WorkDays) });
        }

        if (WorkDays.Any(d => d is not ("Mon" or "Tue" or "Wed" or "Thu" or "Fri")))
        {
            yield return new ValidationResult("Work days must be Monday to Friday.", new[] { nameof(WorkDays) });
        }
    }
}