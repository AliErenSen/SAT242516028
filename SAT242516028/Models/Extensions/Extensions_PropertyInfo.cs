using System.ComponentModel.DataAnnotations;
using System.Reflection;

public static class Extensions_PropertyInfo
{
    public static bool Sortable(this PropertyInfo prop)
    {
        var value = false;
        if (prop.GetCustomAttribute(typeof(SortableAttribute)) is SortableAttribute a)
            value = a.Value;
        return value;
    }

    public static bool Editable(this PropertyInfo prop)
    {
        var value = false;
        if (prop.GetCustomAttribute(typeof(EditableAttribute)) is EditableAttribute a)
            value = a.AllowEdit;
        return value;
    }

    public static bool Viewable(this PropertyInfo prop)
    {
        var value = false;
        if (prop.GetCustomAttribute(typeof(ViewableAttribute)) is ViewableAttribute a)
            value = a.Value;
        return value;
    }

    public static string LocalizedDescription(this PropertyInfo propertyInfo)
    {
        try
        {
            var attributes = (LocalizedDescriptionAttribute[])propertyInfo
                .GetCustomAttributes(typeof(LocalizedDescriptionAttribute),
                    false);
            return attributes != null && attributes.Length > 0
                ? attributes[0].Description
                : propertyInfo.Name;
        }
        catch (Exception)
        {
            return propertyInfo.Name;
        }
    }
}