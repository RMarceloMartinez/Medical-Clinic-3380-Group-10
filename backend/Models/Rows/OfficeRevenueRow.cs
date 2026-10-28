namespace ClinicApi.Models;

public class OfficeRevenueRow
{
    public int OfficeID { get; set; }

    public string OfficeStreetAddress { get; set; } = string.Empty;

    public int CompletedVisits { get; set; }

    public decimal Billed { get; set; } 

    public decimal Collected { get; set; }

    public decimal Refunded { get; set; }

    public decimal Outstanding { get; set; }

    public decimal CashCollected { get; set; }

    public decimal CreditCardCollected { get; set; }

    public decimal DebitCardCollected { get; set; }

    public decimal InsuranceCollected { get; set; }

    public decimal CheckCollected { get; set; }
}   