namespace ClinicApi.Models;

// What the nurse's "View chart" screen receives
public class PatientChartResponse
{
    public List<AllergyRow> Allergies { get; set; } = new();
    public List<MedicationRow> Medications { get; set; } = new();
    public List<ConditionRow> Conditions { get; set; } = new();
    public List<PastVisitRow> PastVisits { get; set; } = new();
}
