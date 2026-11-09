using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

// What the doctor's prescription form sends. Lengths match the Prescription columns.
public class CreatePrescriptionRequest
{
    [Required(ErrorMessage = "Enter the medication.")]
    [MaxLength(50)]
    public string MedicationName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Enter the dosage.")]
    [MaxLength(20)]
    public string Dosage { get; set; } = string.Empty;

    [Required(ErrorMessage = "Enter how often.")]
    [MaxLength(20)]
    public string Frequency { get; set; } = string.Empty;

    [Required(ErrorMessage = "Enter for how long.")]
    [MaxLength(20)]
    public string Duration { get; set; } = string.Empty;

    [MaxLength(100)]
    public string? Instructions { get; set; }

    [Required(ErrorMessage = "Choose a pharmacy.")]
    [MaxLength(60)]
    public string Pharmacy { get; set; } = string.Empty;

    // True once the doctor has seen the allergy warning and chose to prescribe anyway
    public bool ConfirmAllergy { get; set; }
}
