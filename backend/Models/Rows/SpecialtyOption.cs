namespace ClinicApi.Models;

// One choice in the doctor's specialty dropdown
public class SpecialtyOption
{
    public string Name { get; set; } = "";
    public decimal VisitFee { get; set; }
}