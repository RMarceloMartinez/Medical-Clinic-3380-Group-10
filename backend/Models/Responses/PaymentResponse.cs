namespace ClinicApi.Models;

public class PaymentResponse
{
    public int PaymentID { get; set; }
    public int AppointmentID { get; set; }
    public int InstallmentNumber { get; set; }
    public DateOnly PaymentDate { get; set; }
    public string PayStatus { get; set; } = string.Empty;

    public List<PaymentDetailResponse> Details { get; set; } = new();

    public decimal TotalAmount =>
        Details.Sum(detail => detail.AmountApplied);
}

public class PaymentDetailResponse
{
    public int MethodID { get; set; }
    public string MethodName { get; set; } = string.Empty;
    public decimal AmountApplied { get; set; }
}