namespace ClinicApi.Models;

// One doctor + office the logged-in patient is allowed to book
public class BookableDoctorRow
{
    public int DoctorID { get; set; }
    public int OfficeID { get; set; }
    public string DoctorName { get; set; } = string.Empty;
    public string Specialty { get; set; } = string.Empty;
    public string OfficeAddress { get; set; } = string.Empty;
    public string WorkDays { get; set; } = string.Empty;      // e.g. "Mon, Wed, Fri"
    public string OfficeHours { get; set; } = string.Empty;   // e.g. "08:00-17:00"
    public int? ReferralID { get; set; }                       // null = primary doctor
    public decimal VisitFee { get; set; }
}