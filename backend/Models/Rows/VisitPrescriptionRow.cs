namespace ClinicApi.Models;

// One prescription written during a visit
public class VisitPrescriptionRow
{
    public int PrescriptionID { get; set; }
    public string MedicationName { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string Frequency { get; set; } = string.Empty;
    public string Duration { get; set; } = string.Empty;
    public string? Instructions { get; set; }
    public string? Pharmacy { get; set; }
}
