using Attributes;
using SAT242516028.Models.MyResource;
using System.ComponentModel;
using R = SAT242516028.Models.MyResource.MyResource;

namespace MyEnums;

public enum Operations
{
    [Color("primary"), LocalizedDescription("List", typeof(R))]
    List,

    [Color("info"), LocalizedDescription("Detail", typeof(R))]
    Detail,

    [Color("success"), LocalizedDescription("Add", typeof(R))]
    Add,

    [Color("warning"), LocalizedDescription("Update", typeof(R))]
    Update,

    [Color("danger"), LocalizedDescription("Remove", typeof(R))]
    Remove,

    [Color("dark"), LocalizedDescription("Cancel", typeof(R))]
    Cancel,

    [Color("secondary"), LocalizedDescription("Reset", typeof(R))]
    Reset
}
