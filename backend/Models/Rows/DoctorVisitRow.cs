namespace ClinicApi.Models;

// One visit in the doctor's "My visits" list
public class DoctorVisitRow
{
    public int AppointmentID { get; set; }
    public int PatientID { get; set; }
    public DateTime AppointmentDateTime { get; set; }
    public string AppointStatus { get; set; } = "";
    public string PatientName { get; set; } = "";
    public string OfficeAddress { get; set; } = "";
    public bool VitalsRecorded { get; set; }

    // Set by the nurse: "Checked in", "Waiting", "Ready for doctor", or null if not checked in yet
    public string? CheckInStatus { get; set; }
}
