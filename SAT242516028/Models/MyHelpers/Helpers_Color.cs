namespace MyHelpers
{
    public class Helpers_Color
    {
        public static IEnumerable<(string bg, string border)> GetColors(int count)
        {
            var palette = new List<(string bg, string border)>
            {
                ("rgba(255, 99, 132, 0.2)", "rgba(255, 99, 132, 1)"),   // Kırmızı
                ("rgba(54, 162, 235, 0.2)", "rgba(54, 162, 235, 1)"),   // Mavi
                ("rgba(255, 206, 86, 0.2)", "rgba(255, 206, 86, 1)"),   // Sarı
                ("rgba(75, 192, 192, 0.2)", "rgba(75, 192, 192, 1)"),   // Yeşil
                ("rgba(153, 102, 255, 0.2)", "rgba(153, 102, 255, 1)"), // Mor
                ("rgba(255, 159, 64, 0.2)", "rgba(255, 159, 64, 1)")    // Turuncu
            };

            for (int i = 0; i < count; i++)
            {
                // Eğer seri sayısı paletten fazlaysa başa döner
                yield return palette[i % palette.Count];
            }
        }
    }
}