namespace ClinicApi.Models;

// R3: one visit behind a report
public class VisitDetailRow
{
    public int AppointmentID { get; set; }

    public DateTime VisitDateTime { get; set; }

    public string PatientName { get; set; } = string.Empty;

    public string DoctorName { get; set; } = string.Empty;

    public string Specialty { get; set; } = string.Empty;

    public string OfficeStreetAddress { get; set; } = string.Empty;

    public string AppointStatus { get; set; } = string.Empty;

    public string? CancelledBy { get; set; }

    public decimal TotalCost { get; set; }

    public decimal AmountPaid { get; set; }

    public decimal? CancellationFee { get; set; }

    public string? Diagnoses { get; set; }
}
