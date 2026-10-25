namespace ClinicApi.Models;

public class PatientResponse
{
    public int PatientID { get; set; }

    public string FirstName { get; set; } = string.Empty;
    public string? MiddleName { get; set; }
    public string LastName { get; set; } = string.Empty;

    public string StreetAddress { get; set; } = string.Empty;
    public string? ApartmentNum { get; set; }
    public string City { get; set; } = string.Empty;
    public string State { get; set; } = string.Empty;
    public string ZipCode { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;

    public string Phone { get; set; } = string.Empty;
    public string Sex { get; set; } = string.Empty;
    public DateOnly DateOfBirth { get; set; }
    public string Email { get; set; } = string.Empty;
}