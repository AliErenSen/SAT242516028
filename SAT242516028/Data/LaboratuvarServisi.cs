using Microsoft.Data.SqlClient;
using SAT242516028.Models;
using System.Data;
using Microsoft.Extensions.Configuration;

namespace SAT242516028.Data
{
    public class LaboratuvarServisi 
    {
        private readonly string _connectionString;

        public LaboratuvarServisi(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

      
        private async Task<List<T>> GetListFromSp<T>(string spName, List<SqlParameter>? parameters = null) where T : new()
        {
            var list = new List<T>();
            using (var con = new SqlConnection(_connectionString))
            {
                var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure };
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters.ToArray());
                }
                await con.OpenAsync();
                var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    T item = new T();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        var prop = typeof(T).GetProperty(reader.GetName(i));
                        if (prop != null && !reader.IsDBNull(i))
                        {
                            prop.SetValue(item, reader.GetValue(i));
                        }
                    }
                    list.Add(item);
                }
            }
            return list;
        }

        private async Task ExecuteSp(string spName, List<SqlParameter> parameters)
        {
            using (var con = new SqlConnection(_connectionString))
            {
                var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure };
                cmd.Parameters.AddRange(parameters.ToArray());
                await con.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }
        }

        
        public async Task<List<TestTanimi>> TestTanimiListeleAsync()
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@Operation", "list") };
           
            return await GetListFromSp<TestTanimi>("sp_TestTanimi_Yonet", parameters);
        }
        public async Task TestTanimiKaydetAsync(TestTanimi test, string operation)
        {
            var parameters = new List<SqlParameter>
            {
                new SqlParameter("@Operation", operation),
                new SqlParameter("@Id", test.Id),
                
                new SqlParameter("@TestKodu", test.TestKodu),
                new SqlParameter("@TestAdi", test.TestAdi),
                new SqlParameter("@Birim", (object)test.Birim ?? DBNull.Value),
                new SqlParameter("@ReferansAralik", (object)test.ReferansAralik ?? DBNull.Value)
            };
            
            await ExecuteSp("sp_TestTanimi_Yonet", parameters);
        }
        public async Task TestTanimiSilAsync(int id)
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@Operation", "delete"), new SqlParameter("@Id", id) };
            
            await ExecuteSp("sp_TestTanimi_Yonet", parameters);
        }

       
        public async Task<List<Hasta>> HastaListeleAsync()
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@Operation", "list") };
           
            return await GetListFromSp<Hasta>("sp_Hasta_Yonet", parameters);
        }
        public async Task HastaKaydetAsync(Hasta hasta, string operation)
        {
            var parameters = new List<SqlParameter>
            {
                new SqlParameter("@Operation", operation),
                new SqlParameter("@Id", hasta.Id),
                
                new SqlParameter("@TCKimlikNo", hasta.TCKimlikNo),
                new SqlParameter("@Ad", hasta.Ad),
                new SqlParameter("@Soyad", hasta.Soyad),
                new SqlParameter("@DogumTarihi", hasta.DogumTarihi),
                new SqlParameter("@Cinsiyet", (object)hasta.Cinsiyet ?? DBNull.Value),
                new SqlParameter("@Telefon", (object)hasta.Telefon ?? DBNull.Value),
                new SqlParameter("@Aktif", hasta.Aktif)
            };
            
            await ExecuteSp("sp_Hasta_Yonet", parameters);
        }
        public async Task HastaSilAsync(int id)
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@Operation", "delete"), new SqlParameter("@Id", id) };
            
            await ExecuteSp("sp_Hasta_Yonet", parameters);
        }

        
        public async Task<List<Rapor>> GetBekleyenRaporlarAsync()
        {
            
            return await GetListFromSp<Rapor>("sp_Rapor_Listele_Bekleyen", null);
        }

        
        public async Task<List<Sonuc>> GetRaporSonuclariAsync(int raporId)
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@RaporId", raporId) };
            
            return await GetListFromSp<Sonuc>("sp_Sonuc_Listele_ByRaporId", parameters);
        }

        
        public async Task RaporOlusturAsync(int hastaId, int doktorId, string aciklama)
        {
            var parameters = new List<SqlParameter> {
                new SqlParameter("@HastaId", hastaId),
                new SqlParameter("@DoktorId", doktorId),
                new SqlParameter("@Aciklama", (object)aciklama ?? DBNull.Value)
            };
            
            await ExecuteSp("sp_Rapor_Olustur", parameters);
        }

       
        public async Task SonucEkleAsync(int raporId, int testTanimiId, string deger)
        {
            var parameters = new List<SqlParameter> {
                new SqlParameter("@RaporId", raporId),
                new SqlParameter("@TestTanimiId", testTanimiId),
                new SqlParameter("@Deger", deger)
            };
            
            await ExecuteSp("sp_Sonuc_Ekle", parameters);
        }

        
        public async Task RaporOnaylaAsync(int raporId)
        {
            var parameters = new List<SqlParameter> { new SqlParameter("@RaporId", raporId) };
            
            await ExecuteSp("sp_Rapor_Onayla", parameters);
        }

     
        public async Task<List<Doktor>> DoktorListeleAsync()
        {
            
            return await GetListFromSp<Doktor>("sp_Doktor_Listele", null);
        }

       
    }
}

