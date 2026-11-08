using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// What the doctor's notes form sends the limits matches to the MedicalRecord column sizes
public class SaveNotesRequest
{
    [MaxLength(500)] public string? ClinicalNotes { get; set; }
    [MaxLength(200)] public string? TreatmentPlan { get; set; }
    [MaxLength(200)] public string? FollowUp { get; set; }
}
