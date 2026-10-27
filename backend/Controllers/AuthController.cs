using System.Security.Claims;
using ClinicApi.Models;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.Data.SqlClient;

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

    
    [AllowAnonymous]
    [HttpPost("register")]                                // POST /api/auth/register
    [Consumes("application/json")]
    public async Task<IActionResult> Register(
        [FromBody] RegisterPatientRequest request,
        [FromServices] IAntiforgery antiforgery,
        CancellationToken cancellationToken)
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

        if (User.Identity?.IsAuthenticated == true)
        {
            return BadRequest(new
            {
                message = "Log out before creating a new account."
            });
        }

        try
        {
            int patientId = await _authService.RegisterPatientAsync(
                request, cancellationToken);

            return Created("/api/auth/me", new { patientID = patientId });
        }
        catch (ArgumentException ex)                      // e.g. not a primary care doctor
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)   // a UNIQUE rule failed
        {
            string message =
                ex.Message.Contains("UQ_UserAccount_Username")
                    ? "That username is already taken."
                : ex.Message.Contains("UQ_Member_Email")
                    ? "An account with that email already exists."
                : ex.Message.Contains("UQ_Member_SSN")
                    ? "That SSN is already registered. Please call the clinic for access to your account."
                : "Some of these details are already registered.";

            return Conflict(new { message });
        }
        catch (SqlException ex) when (ex.Number == 547)   // a CHECK rule failed
        {
            return BadRequest(new
            {
                message = "Some details are not valid. Check the form and try again."
            });
        }
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