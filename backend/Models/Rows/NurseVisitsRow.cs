namespace ClinicApi.Models;

// One visit in the nurse's list (today / this week at her office)
public class NurseVisitRow
{
    public int AppointmentID { get; set; }
    public int PatientID { get; set; }
    public DateTime AppointmentDateTime { get; set; }
    public string PatientName { get; set; } = "";
    public string DoctorName { get; set; } = "";
    public bool VitalsRecorded { get; set; }

    // "Waiting for nurse" (no vitals), "Waiting for doctor" (vitals, not completed), "Seen" (completed)
    public string VisitStatus { get; set; } = "";

    // "Checked in", "Waiting", "Ready for doctor", or null if not checked in yet
    public string? CheckInStatus { get; set; }
}
