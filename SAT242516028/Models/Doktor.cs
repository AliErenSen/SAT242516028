namespace SAT242516028.Models
{
    public class Doktor
    {
        public int Id { get; set; }
        public string AdSoyad { get; set; }
        public string UzmanlikAlani { get; set; } 
        public string DiplomaNo { get; set; }

        
        public virtual ICollection<Rapor> Raporlar { get; set; }
    }
}
