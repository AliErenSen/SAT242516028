using System.ComponentModel;
using System.Resources;

public class LocalizedDescriptionAttribute(string resourceKey, Type resourceType)
    : DescriptionAttribute
{
    private readonly ResourceManager _resource = new(resourceType);

    public override string Description
    {
        get
        {
            string desc = _resource.GetString(resourceKey);

            return string.IsNullOrEmpty(desc)
                ? $"{resourceKey}"
                : desc;
        }
    }
}