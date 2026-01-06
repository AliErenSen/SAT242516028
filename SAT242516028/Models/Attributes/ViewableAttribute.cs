public class ViewableAttribute(bool value) : Attribute
{
    public bool Value { get; set; } = value;
}
public class SortableAttribute(bool value) : Attribute
{
    public bool Value { get; set; } = value;
}