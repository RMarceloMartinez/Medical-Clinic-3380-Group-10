namespace ClinicApi.Models;

// I added this because Nurse didn't have a way to edit vitals in case of mistake
public class VitalsResponse
{
    public short SystolicBP { get; set; }
    public short DiastolicBP { get; set; }
    public short HeartRate { get; set; }
    public decimal Temperature { get; set; }
    public decimal WeightPounds { get; set; }
    public decimal HeightInches { get; set; }
}