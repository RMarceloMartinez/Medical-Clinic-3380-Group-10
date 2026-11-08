using ClinicApi.Data;
using ClinicApi.Services;
using Microsoft.AspNetCore.Authentication.Cookies;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<SqlConnectionFactory>();

// Add services 

builder.Services.AddControllers();

builder.Services.AddOpenApi();

builder.Services.AddScoped<AuthService>();

builder.Services.AddScoped<PatientService>();

builder.Services.AddScoped<PaymentService>();

builder.Services.AddScoped<AppointmentService>();

builder.Services.AddScoped<NurseService>();

builder.Services.AddScoped<LookupService>();

builder.Services.AddScoped<ReportService    >();

builder.Services.AddScoped<QueryService>();

builder.Services.AddScoped<ReferralService>();

builder.Services.AddScoped<DoctorService>();

builder.Services.AddScoped<EmployeeService>();

builder.Services
    .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = "ClinicAuth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
        options.SlidingExpiration = true;
        options.Events.OnRedirectToLogin = context =>
        {
            context.Response.StatusCode = 401;
            return Task.CompletedTask;
        };

        options.Events.OnRedirectToAccessDenied = context =>
        {
            context.Response.StatusCode = 403;
            return Task.CompletedTask;
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = "X-CSRF-TOKEN";
    options.Cookie.Name = "ClinicCsrf";
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Lax;
});


var app = builder.Build();

// Configure the HTTP request 
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

   // Serve the built React site (files in wwwroot) from the same address as the API.
   // Same address = the login and CSRF cookies work without CORS.
   // On your laptop there is no wwwroot, so nothing changes: keep using npm run dev.
app.UseDefaultFiles();   // "/" -> index.html
// Same cache rules for the static files AND for the index.html fallback below
var staticFileOptions = new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        var headers = ctx.Context.Response.Headers;

        if (ctx.File.Name.EndsWith(".html"))
        {
            headers.CacheControl = "no-cache";                              // always check for a new version
        }
        else if (ctx.Context.Request.Path.StartsWithSegments("/assets"))
        {
            headers.CacheControl = "public, max-age=31536000, immutable";   // file names change every build
        }
    }
};
app.UseStaticFiles(staticFileOptions);    // the JS/CSS files Vite builds   


app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
// Page addresses like /staff/patients have no file: send index.html and let React Router pick the page
app.MapFallbackToFile("index.html", staticFileOptions);

app.Run();
