namespace ClinicApi.Models;

public class PastVisitRow
{
    public int AppointmentID { get; set; }
    public DateTime AppointmentDateTime { get; set; }
    public string DoctorName { get; set; } = "";
    public string Office { get; set; } = "";
    public short? SystolicBP { get; set; }
    public short? DiastolicBP { get; set; }
    public short? HeartRate { get; set; }
    public decimal? WeightPounds { get; set; }
}