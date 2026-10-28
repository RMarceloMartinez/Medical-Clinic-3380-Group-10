namespace ClinicApi.Models;

public class LoginResponse
{
    public int AccountID { get; set; }

    public int UserID { get; set; }

    public string Username { get; set; } = string.Empty;

    public string Role { get; set; } = string.Empty;
}