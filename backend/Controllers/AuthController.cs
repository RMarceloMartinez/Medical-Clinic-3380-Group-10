using System.Security.Claims;
using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;

namespace ClinicApi.Controllers;

[ApiController]
[Route("api/auth")]
[ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    [Consumes("application/json")]
    public async Task<ActionResult<LoginResponse>> Login(
        [FromBody] LoginRequest request,
        CancellationToken cancellationToken)
    {
        var account = await _authService.ValidateLoginAsync(
            request, cancellationToken);

        if (account is null)
        {
            return Unauthorized(new
            {
                message = "Invalid username or password."
            });
        }

        var claims = new List<Claim>
        {
            new Claim(
                ClaimTypes.NameIdentifier,
                account.AccountID.ToString()),
            new Claim("UserID", account.UserID.ToString()),
            new Claim(ClaimTypes.Name, account.Username),
            new Claim(ClaimTypes.Role, account.Role)
        };

        var identity = new ClaimsIdentity(
            claims,
            CookieAuthenticationDefaults.AuthenticationScheme);

        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            new ClaimsPrincipal(identity),
            new AuthenticationProperties
            {
                IsPersistent = false,
                AllowRefresh = false
            });

        return Ok(account);
    }

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        return Ok(new
        {
            accountID = User.FindFirstValue(ClaimTypes.NameIdentifier),
            userID = User.FindFirstValue("UserID"),
            username = User.Identity?.Name,
            role = User.FindFirstValue(ClaimTypes.Role)
        });

    }
    [AllowAnonymous]
    [HttpGet("csrf")]
    public IActionResult GetCsrfToken(
        [FromServices] IAntiforgery antiforgery)
    {
        var tokens = antiforgery.GetAndStoreTokens(HttpContext);

        return Ok(new
        {
            token = tokens.RequestToken
        });
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(
        [FromServices] IAntiforgery antiforgery)
    {
        try
        {
            await antiforgery.ValidateRequestAsync(HttpContext);
        }
        catch (AntiforgeryValidationException)
        {
            return BadRequest(new
            {
                message = "Invalid request verification token."
            });
        }

        await HttpContext.SignOutAsync(
            CookieAuthenticationDefaults.AuthenticationScheme);

        return NoContent();
    }
    
}