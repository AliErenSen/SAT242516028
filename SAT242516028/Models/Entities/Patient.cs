using System;
using System.ComponentModel.DataAnnotations;
using SAT242516028.Models.MyResource;

namespace SAT242516028.Entities;

public class Patient
{
    [Sortable(true)]
    [Editable(false)]
    [Viewable(true)]
    [LocalizedDescription("Id", typeof(MyResource))]
    public int Id { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("TCNo", typeof(MyResource))]
    public string TCNo { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("FirstName", typeof(MyResource))]
    public string FirstName { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("LastName", typeof(MyResource))]
    public string LastName { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("Phone", typeof(MyResource))]
    public string Phone { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("BirthDate", typeof(MyResource))]
    public DateTime? BirthDate { get; set; }

    [Sortable(true)]
    [Editable(true)]
    [Viewable(true)]
    [LocalizedDescription("Gender", typeof(MyResource))]
    public string Gender { get; set; }
}