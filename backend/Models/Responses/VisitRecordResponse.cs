namespace ClinicApi.Models;

// A visit's medical record as the doctor sees it: the nurse's vitals plus any saved notes
public class VisitRecordResponse
{
    public short SystolicBP { get; set; }
    public short DiastolicBP { get; set; }
    public short HeartRate { get; set; }
    public decimal Temperature { get; set; }
    public decimal WeightPounds { get; set; }
    public decimal HeightInches { get; set; }
    public string? ClinicalNotes { get; set; }
    public string? TreatmentPlan { get; set; }
    public string? FollowUp { get; set; }
}
