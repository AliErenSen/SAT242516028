namespace Entities;

public class TestDefinitions
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string Unit { get; set; } = "";
    public decimal? ReferenceRangeMin { get; set; }
    public decimal? ReferenceRangeMax { get; set; }
    public decimal Price { get; set; }
    public bool IsActive { get; set; } = true;

    public int TotalRecordCount { get; set; }
}