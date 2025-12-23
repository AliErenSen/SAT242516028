namespace Entities;

public class Patients
{
    public int Id { get; set; }
    public string TCNumber { get; set; } = "";
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public string Gender { get; set; } = "";
    public DateTime? BirthDate { get; set; }
    public string Phone { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Pagination (Sayfalama) için SP'den dönecek ekstra kolon
    public int TotalRecordCount { get; set; }
}