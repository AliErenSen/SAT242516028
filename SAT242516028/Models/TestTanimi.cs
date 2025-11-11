namespace SAT242516028.Models
{
    public class TestTanimi
    {
        public int Id { get; set; }
        public string TestKodu { get; set; } 
        public string TestAdi { get; set; } 
        public string Birim { get; set; } 
        public string ReferansAralik { get; set; } 

       
        public virtual ICollection<Sonuc> Sonuclar { get; set; }
    }
}
