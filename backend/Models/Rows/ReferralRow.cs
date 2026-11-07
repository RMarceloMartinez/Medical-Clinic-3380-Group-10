namespace ClinicApi.Models;

// One referral in a doctor's "Referrals I sent" list
public class ReferralRow
{
    public int ReferralID { get; set; }

    public string PatientName { get; set; } = string.Empty;

    public string SpecialistName { get; set; } = string.Empty;

    public string Specialty { get; set; } = string.Empty;

    public DateTime DateIssued { get; set; }

    public string RefStatus { get; set; } = string.Empty;
}
