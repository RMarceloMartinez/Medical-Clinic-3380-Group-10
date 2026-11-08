namespace ClinicApi.Models;

// The vitals already saved for a visit (used to fill in the nurse's edit screen)
public class VitalsResponse
{
    public short SystolicBP { get; set; }
    public short DiastolicBP { get; set; }
    public short HeartRate { get; set; }
    public decimal Temperature { get; set; }
    public decimal WeightPounds { get; set; }
    public decimal HeightInches { get; set; }
}
