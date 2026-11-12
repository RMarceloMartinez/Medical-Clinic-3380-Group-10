namespace ClinicApi.Models;

public class AllergyRequest
{
    public string Allergen { get; set; } = "";
    public string ReactionType { get; set; } = "";
    public string Severity { get; set; } = "";
    public DateTime? DateIdentified { get; set; }
}