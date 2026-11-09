namespace ClinicApi.Models;

// What the nurse's check-in buttons send: "Checked in", "Waiting" or "Ready for doctor"
public class SetCheckInRequest
{
    public string CheckInStatus { get; set; } = "";
}
