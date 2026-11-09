namespace ClinicApi.Models;

// The vitals (and nursing notes) already saved for a visit, used to fill in the nurse's visit screen
public class VitalsResponse
{
    public short SystolicBP { get; set; }
    public short DiastolicBP { get; set; }
    public short HeartRate { get; set; }
    public decimal Temperature { get; set; }
    public decimal WeightPounds { get; set; }
    public decimal HeightInches { get; set; }
    public string? NursingNotes { get; set; }
}
