namespace ClinicApi.Models;

public class AppointmentResponse
{
    public int AppointmentID  { get; set; }

    public int OfficeID  { get; set; }

    public int DoctorID { get; set; }

    public int PatientID { get; set; }
    
    public int? ReferralID { get; set; }

    public DateTime AppointmentDateTime { get; set; }

    public string AppointStatus { get; set;} = string.Empty;

    public decimal TotalCost { get; set; }

    public string Channel { get; set; } = string.Empty;

    public string? CancelReason { get; set; }

    public string? CancelledBy { get; set; }
    
}