namespace ClinicApi.Models;

public class NurseVisitRow
{
    public int AppointmentID { get; set; }
    public int PatientID { get; set; }
    public DateTime AppointmentDateTime { get; set; }
    public string PatientName { get; set; } = "";
    public string DoctorName { get; set; } = "";
    public bool VitalsRecorded { get; set; }
}