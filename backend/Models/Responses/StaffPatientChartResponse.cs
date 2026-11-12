namespace ClinicApi.Models;

public class StaffPatientChartResponse
{
    public int PatientID { get; set; }
    public string PatientName { get; set; } = "";

    public List<AllergyRow> Allergies { get; set; } = new();
    public List<ConditionRow> Conditions { get; set; } = new();
    public List<StaffChartVisit> Visits { get; set; } = new();
}

public class StaffChartVisit
{
    public int AppointmentID { get; set; }
    public DateTime VisitDate { get; set; }
    public string AppointmentStatus { get; set; } = "";
    public string? VisitReason { get; set; }

    public short? SystolicBP { get; set; }
    public short? DiastolicBP { get; set; }
    public short? HeartRate { get; set; }
    public decimal? Temperature { get; set; }
    public decimal? WeightPounds { get; set; }
    public decimal? HeightInches { get; set; }

    public string? NursingNotes { get; set; }
    public string? DoctorNotes { get; set; }

    public List<StaffChartDiagnosis> Diagnoses { get; set; } = new();
    public List<StaffChartPrescription> Prescriptions { get; set; } = new();
}

public class StaffChartDiagnosis
{
    public int DiagnosisID { get; set; }
    public string DiagnosisDescription { get; set; } = "";
    public string DiagnosisType { get; set; } = "";
}

public class StaffChartPrescription
{
    public int PrescriptionID { get; set; }
    public string MedicationName { get; set; } = "";
    public string Dosage { get; set; } = "";
    public string Frequency { get; set; } = "";
    public string Duration { get; set; } = "";
    public string? Instructions { get; set; }
    public string? Pharmacy { get; set; }
}