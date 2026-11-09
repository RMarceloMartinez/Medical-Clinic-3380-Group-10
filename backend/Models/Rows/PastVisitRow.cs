namespace ClinicApi.Models;

// A completed visit, with the vitals and the doctor's notes from it (null if no record was kept)
public class PastVisitRow
{
    public int AppointmentID { get; set; }
    public DateTime AppointmentDateTime { get; set; }
    public string DoctorName { get; set; } = "";
    public string Office { get; set; } = "";
    public short? SystolicBP { get; set; }
    public short? DiastolicBP { get; set; }
    public short? HeartRate { get; set; }
    public decimal? Temperature { get; set; }
    public decimal? WeightPounds { get; set; }
    public string? ClinicalNotes { get; set; }
    public string? TreatmentPlan { get; set; }
    public string? FollowUp { get; set; }
}
