// 1. ADIM: Namespace'leri yeni proje adýyla (SAT242516028) güncelledim
using SAT242516028.Components;
using SAT242516028.Components.Account;
using SAT242516028.Data;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// 2. ADIM: Senin Auth (Giriþ/Çýkýþ) ayarlarýnýn HÝÇBÝRÝNE DOKUNMADIM.
// Bu ayarlar Kutuphane projesinde çalýþýyorsa, burada da çalýþacaktýr.
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<IdentityUserAccessor>();
builder.Services.AddScoped<IdentityRedirectManager>();
builder.Services.AddScoped<AuthenticationStateProvider, IdentityRevalidatingAuthenticationStateProvider>();

builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = IdentityConstants.ApplicationScheme;
    options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
})
    .AddIdentityCookies();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

// ApplicationUser kullanmaya devam ediyoruz, bu doðru.
builder.Services.AddIdentityCore<ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddSignInManager()
    .AddDefaultTokenProviders();

IServiceCollection serviceCollection = builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityNoOpEmailSender>();

// 3. ADIM: EN ÖNEMLÝ DEÐÝÞÝKLÝK
// KutuphaneServisi için gerekli olan IConfiguration kaydýný korudum.
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

// KutuphaneServisi kaydýný, LaboratuvarServisi olarak deðiþtirdim.
// "No registered service of type LaboratuvarServisi" hatasýný bu satýr çözer.
builder.Services.AddScoped<LaboratuvarServisi>();
// --- DEÐÝÞÝKLÝK BÝTTÝ ---

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

// Add additional endpoints required by the Identity /Account Razor components.
app.MapAdditionalIdentityEndpoints();

app.Run();