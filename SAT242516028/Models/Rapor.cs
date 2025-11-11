using SAT242516028.Models;
using System.ComponentModel.DataAnnotations;

namespace SAT242516028.Models
{
    public class Rapor
    {
        public int Id { get; set; }
        public int HastaId { get; set; }
        public int DoktorId { get; set; }
        public DateTime RaporTarihi { get; set; }
        public string Durum { get; set; }
        public string? Aciklama { get; set; }

      

        [Display(Name = "Hasta Adı")]
        public string? HastaAdSoyad { get; set; } 

        [Display(Name = "Doktor Adı")]
        public string? DoktorAdSoyad { get; set; } 
    }
}




    
   

