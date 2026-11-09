using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// What the nurse's "Nursing notes" tab sends. The limit matches MedicalRecord.NursingNotes.
public class SaveNursingNotesRequest
{
    [MaxLength(500)] public string? NursingNotes { get; set; }
}
