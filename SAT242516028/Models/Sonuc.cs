namespace SAT242516028.Models
{
    public class Sonuc
    {
        public int Id { get; set; }
        public int RaporId { get; set; }
        public int TestTanimiId { get; set; }
        public string Deger { get; set; }
        public string? Aciklama { get; set; }

      

        public string? TestAdi { get; set; }
        public string? Birim { get; set; }
        public string? ReferansAralik { get; set; }
    }
}

