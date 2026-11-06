using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class RecordVitalsRequest
{
    [Range(50, 300)] public short SystolicBP { get; set; }
    [Range(20, 200)] public short DiastolicBP { get; set; }
    [Range(20, 300)] public short HeartRate { get; set; }
    [Range(56, 110)] public decimal Temperature { get; set; }
    [Range(0.1, 1500)] public decimal WeightPounds { get; set; }
    [Range(0.1, 100)] public decimal HeightInches { get; set; }
}