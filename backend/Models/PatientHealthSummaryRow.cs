namespace ClinicApi.Models;

public class PatientHealthSummaryRow
{
    public int PatientID { get; set; }
    public string PatientFirstName { get; set; } = "";
    public string PatientLastName { get; set; } = "";
    public string Category { get; set; } = "";
    public string ItemName { get; set; } = "";
    public string? Detail { get; set; }
    public DateTime? ItemDate { get; set; }
}