namespace ClinicApi.Models;

public class AppointmentActivityRow
{
    public int DoctorID { get; set; }

    public string DoctorFirstName { get; set; } = string.Empty;

    public string DoctorLastName { get; set; } = string.Empty;

    public int OfficeID { get; set; }

    public string OfficeStreetAddress { get; set; } = string.Empty;

    public int TotalAppointments { get; set; }

    public int Scheduled { get; set; }

    public int Completed { get; set; }

    public int Cancelled { get; set; }

    public int CancelledByPatient { get; set; }

    public int CancelledByDoctor { get; set; }

    public int CancelledByStaff { get; set; }

    public decimal CancellationRate { get; set; }

}   