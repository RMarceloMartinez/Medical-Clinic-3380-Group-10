namespace ClinicApi.Models;

public class PatientChartResponse
{
    public List<AllergyRow> Allergies { get; set; } = new();
    public List<ConditionRow> Conditions { get; set; } = new();
    public List<PastVisitRow> PastVisits { get; set; } = new();
}