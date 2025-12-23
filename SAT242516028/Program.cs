using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SAT242516028.Components;
using SAT242516028.Components.Account;
using SAT242516028.Data;
using DbContexts;
using UnitOfWorks;
using Providers;
using Services;
using QuestPDF.Infrastructure;
using System.Globalization;             // YENÝ: Dil ayarlarý için
using Microsoft.AspNetCore.Localization; // YENÝ: Dil servisi için

var builder = WebApplication.CreateBuilder(args);

// --- 0. QUESTPDF LÝSANS AYARI ---
QuestPDF.Settings.License = LicenseType.Community;

// 1. SERVICES (HÝZMETLER)

// --- YENÝ EKLENDÝ: DÝL SERVÝSLERÝ ---
builder.Services.AddLocalization(); // Varsayýlan kaynak yolu
builder.Services.AddControllers();  // Dil deðiþtirme API'si (Cookie) için gerekli
// ------------------------------------

// Blazor Servisleri
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// Kimlik Doðrulama Durumu
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<IdentityUserAccessor>();
builder.Services.AddScoped<IdentityRedirectManager>();

// Authentication State Provider
builder.Services.AddScoped<AuthenticationStateProvider, IdentityRevalidatingAuthenticationStateProvider>();

// Kimlik Doðrulama Ayarlarý
builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = IdentityConstants.ApplicationScheme;
    options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
})
    .AddIdentityCookies();

// Veritabaný Baðlantý Cümlesi
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

// 2. VERÝTABANI BAÐLANTILARI

// A. Identity (Kullanýcýlar)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

// B. Proje Verileri (Hastalar, Testler vb.)
builder.Services.AddDbContext<MyDbModel_DbContext>(options =>
    options.UseSqlServer(connectionString));

// 3. IDENTITY CORE VE ROL AYARLARI
builder.Services.AddIdentityCore<ApplicationUser>(options =>
{
    options.SignIn.RequireConfirmedAccount = false;
    options.Password.RequireDigit = false;
    options.Password.RequiredLength = 3;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireLowercase = false;
})
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddSignInManager()
    .AddDefaultTokenProviders();

builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityNoOpEmailSender>();

// 4. ÖZEL SERVÝSLER

// Temel Veritabaný Katmaný
builder.Services.AddScoped<IMyDbModel_UnitOfWork, MyDbModel_UnitOfWork<MyDbModel_DbContext>>();
builder.Services.AddScoped<IMyDbModel_Provider, MyDbModel_Provider>();

// Ýþ Mantýðý Servisleri
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPatientService, PatientService>();
builder.Services.AddScoped<ILabService, LabService>();

// Raporlama Servisi
builder.Services.AddScoped<IReportService, ReportService>();

// Hata ayýklama filtresi
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

// Login Yolu Ayarlamasý
builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath = "/login";
    options.AccessDeniedPath = "/access-denied";
});

var app = builder.Build();

// --- YENÝ EKLENDÝ: DÝL AYARLARI (MIDDLEWARE) ---
var supportedCultures = new[] { "tr-TR", "en-US" };
var localizationOptions = new RequestLocalizationOptions()
    .SetDefaultCulture("tr-TR") // Varsayýlan Türkçe
    .AddSupportedCultures(supportedCultures)
    .AddSupportedUICultures(supportedCultures);

app.UseRequestLocalization(localizationOptions);
// ----------------------------------------------

// 5. PIPELINE

if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAntiforgery();

// Controller'larý (Dil deðiþtirme API'sini) haritala
// DÝKKAT: Bu satýr olmazsa dil deðiþtirme butonu çalýþmaz!
app.MapControllers();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.MapAdditionalIdentityEndpoints();



app.Run();