namespace ClinicApi.Models;

public class ConditionRequest
{
    public string ConditionName { get; set; } = "";
    public string ConditionType { get; set; } = "";
    public string Severity { get; set; } = "";
    public bool IsHereditary { get; set; }
    public DateTime? DateDiagnosed { get; set; }
}