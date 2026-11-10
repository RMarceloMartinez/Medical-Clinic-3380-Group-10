namespace ClinicApi.Models;

// A doctor the logged-in patient can see on the booking page but cannot book yet,
// with the reason why (needs a referral, or is not their primary doctor)
public class OtherDoctorRow
{
    public int DoctorID { get; set; }
    public int OfficeID { get; set; }
    public string DoctorName { get; set; } = string.Empty;
    public string Specialty { get; set; } = string.Empty;
    public string OfficeAddress { get; set; } = string.Empty;
    public string WorkDays { get; set; } = string.Empty;
    public string OfficeHours { get; set; } = string.Empty;
    public decimal VisitFee { get; set; }
    public string Note { get; set; } = string.Empty;
}
