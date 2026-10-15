using System.ComponentModel.DataAnnotations;

namespace ClinicApi.Models;

public class LoginRequest
{
    [Required]
    [StringLength(25)]
    public string Username { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}