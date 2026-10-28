namespace ClinicApi.Models;

public class DoctorWeekAppointmentRow
{
    public DateTime Date_Time { get; set; }

    public string PatientName { get; set; } = string.Empty;
 
    public string Office { get; set; } = string.Empty;

    public string AppointStatus { get; set; } = string.Empty;
}   