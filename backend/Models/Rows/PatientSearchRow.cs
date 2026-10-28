namespace ClinicApi.Models;

public class PatientSearchRow
{
    public int PatientID { get; set; }

    public string PatientName { get; set; } = string.Empty;

    public DateOnly DateOfBirth { get; set; }

    public string Phone { get; set; } = string.Empty;
}   