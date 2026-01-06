using System;
using System.ComponentModel.DataAnnotations;
using SAT242516028.Models.MyResource;

namespace SAT242516028.Entities;

public class LabTest
{
    [Sortable(true)]
    [Editable(false)]
    [Viewable(true)]
    [LocalizedDescription("Id", typeof(MyResource))]
    public int Id { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("TestCode", typeof(MyResource))]
    public string TestCode { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("TestName", typeof(MyResource))]
    public string TestName { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("Unit", typeof(MyResource))]
    public string Unit { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("ReferenceMin", typeof(MyResource))]
    public decimal? ReferenceMin { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("ReferenceMax", typeof(MyResource))]
    public decimal? ReferenceMax { get; set; }
}