namespace ClinicApi.Models;

// A prescription from a past visit
public class MedicationRow
{
    public int RecordID { get; set; }
    public int PrescriptionID { get; set; }
    public string MedicationName { get; set; } = "";
    public string Dosage { get; set; } = "";
    public string Frequency { get; set; } = "";
    public string Duration { get; set; } = "";
    public string? Instructions { get; set; }
    public DateTime PrescribedOn { get; set; }
    public string DoctorName { get; set; } = "";
}
