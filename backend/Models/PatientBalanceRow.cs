namespace ClinicApi.Models;

public class PatientBalanceRow
{
    public decimal Billed { get; set; }

    public decimal Paid { get; set; }

    public decimal Balance { get; set; }
}   