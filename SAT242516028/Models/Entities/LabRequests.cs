namespace Entities;

public class LabRequests
{
    public int Id { get; set; }
    public int PatientId { get; set; }
    public string DoctorName { get; set; } = "";
    public DateTime RequestDate { get; set; } = DateTime.Now;
    public string Status { get; set; } = "Pending"; // Pending, Completed

    // Join ile gelecek alanlar (View veya SP'den)
    public string PatientName { get; set; } = "";
    public string TCNumber { get; set; } = "";

    public int TotalRecordCount { get; set; }
}