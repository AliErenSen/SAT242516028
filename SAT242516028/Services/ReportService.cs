namespace Services;

using Entities;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

public class ReportService : IReportService
{
    public byte[] GeneratePatientReport(IEnumerable<Patients> patients)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(12));

                // BAŞLIK
                page.Header()
                    .Text("Hasta Listesi Raporu")
                    .SemiBold().FontSize(24).FontColor(Colors.Blue.Medium);

                // İÇERİK (TABLO)
                page.Content()
                    .PaddingVertical(1, Unit.Centimetre)
                    .Table(table =>
                    {
                        // Kolon Genişlikleri
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(30); // Sıra No
                            columns.RelativeColumn();   // TC
                            columns.RelativeColumn();   // Ad
                            columns.RelativeColumn();   // Soyad
                            columns.RelativeColumn();   // Tel
                        });

                        // Tablo Başlığı
                        table.Header(header =>
                        {
                            header.Cell().Element(CellStyle).Text("#");
                            header.Cell().Element(CellStyle).Text("TC Kimlik");
                            header.Cell().Element(CellStyle).Text("Ad");
                            header.Cell().Element(CellStyle).Text("Soyad");
                            header.Cell().Element(CellStyle).Text("Telefon");

                            static IContainer CellStyle(IContainer container)
                            {
                                return container.DefaultTextStyle(x => x.SemiBold())
                                                .PaddingVertical(5)
                                                .BorderBottom(1)
                                                .BorderColor(Colors.Black);
                            }
                        });

                        // Tablo Satırları
                        int i = 1;
                        foreach (var item in patients)
                        {
                            table.Cell().Element(CellStyle).Text(i++);
                            table.Cell().Element(CellStyle).Text(item.TCNumber);
                            table.Cell().Element(CellStyle).Text(item.FirstName);
                            table.Cell().Element(CellStyle).Text(item.LastName);
                            table.Cell().Element(CellStyle).Text(item.Phone);

                            static IContainer CellStyle(IContainer container)
                            {
                                return container.BorderBottom(1)
                                                .BorderColor(Colors.Grey.Lighten2)
                                                .PaddingVertical(5);
                            }
                        }
                    });

                // ALTBİLGİ
                page.Footer()
                    .AlignCenter()
                    .Text(x =>
                    {
                        x.Span("Sayfa ");
                        x.CurrentPageNumber();
                        x.Span(" / ");
                        x.TotalPages();
                    });
            });
        });

        return document.GeneratePdf();
    }

    // Yönerge Madde 24.a gereği ikinci bir tablo raporu
    public byte[] GenerateTestDefReport(IEnumerable<TestDefinitions> tests)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);

                page.Header().Text("Test Tanımları Raporu").FontSize(20).SemiBold();

                page.Content().PaddingVertical(10).Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn();
                        columns.RelativeColumn(2);
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                    });

                    table.Header(header =>
                    {
                        header.Cell().Text("Kod").Bold();
                        header.Cell().Text("Test Adı").Bold();
                        header.Cell().Text("Birim").Bold();
                        header.Cell().Text("Fiyat").Bold();
                    });

                    foreach (var item in tests)
                    {
                        table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(item.Code);
                        table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(item.Name);
                        table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(item.Unit);
                        table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{item.Price} ₺");
                    }
                });
            });
        });

        return document.GeneratePdf();
    }
}