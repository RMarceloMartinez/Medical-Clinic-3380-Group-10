namespace ClinicApi.Models;

public class EmployeeRow
{
    public int EmployeeID { get; set; }
    public string Name { get; set; } = "";
    public string Role { get; set; } = "";
    public string? Office { get; set; }      // NULL for an admin
    public string? Specialty { get; set; }   // doctors only
    public string? WorkDays { get; set; }    // doctors only, e.g. "Mon, Wed, Fri"
    public string? Username { get; set; }    // NULL if the worker has no login
    public DateTime HiringDate { get; set; }
}