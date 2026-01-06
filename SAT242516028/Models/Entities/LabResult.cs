using System;
using System.ComponentModel.DataAnnotations;
using SAT242516028.Models.MyResource;

namespace SAT242516028.Entities;

public class LabResult
{
    [Sortable(true)]
    [Editable(false)]
    [Viewable(true)]
    [LocalizedDescription("Id", typeof(MyResource))]
    public int Id { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("PatientId", typeof(MyResource))]
    public int PatientId { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("LabTestId", typeof(MyResource))]
    public int LabTestId { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("ResultValue", typeof(MyResource))]
    public decimal? ResultValue { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("ResultDate", typeof(MyResource))]
    public DateTime? ResultDate { get; set; }
}