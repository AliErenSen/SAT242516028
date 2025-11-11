using System.ComponentModel.DataAnnotations;
using System.Data;

namespace SAT242516028.Models
{

    public class Hasta
    {
        

        public int Id { get; set; }

        [Required(ErrorMessage = "T.C. Kimlik No zorunludur.")]
        [StringLength(11, MinimumLength = 11, ErrorMessage = "T.C. Kimlik No 11 haneli olmalıdır.")]
        public string TCKimlikNo { get; set; }

        [Required(ErrorMessage = "Ad alanı zorunludur.")]
        public string Ad { get; set; }

        [Required(ErrorMessage = "Soyad alanı zorunludur.")]
        public string Soyad { get; set; }

        public DateTime DogumTarihi { get; set; }

        public string? Cinsiyet { get; set; } 

        public string? Telefon { get; set; }

        public string? Adres { get; set; }

        public bool Aktif { get; set; }
    }
}