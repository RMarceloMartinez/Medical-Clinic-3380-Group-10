using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class CreateReferralRequest
{
    [Required(ErrorMessage = "Choose a patient.")]
    public int? PatientID { get; set; }

    [Required(ErrorMessage = "Choose a specialist.")]
    public int? SpecialistID { get; set; }
}
