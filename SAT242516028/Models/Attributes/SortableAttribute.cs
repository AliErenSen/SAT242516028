namespace SAT242516028.Models.Attributes
{
    public class SortableAttribute(bool value) : Attribute
    {
        public bool Value { get; set; } = value;
    }
}