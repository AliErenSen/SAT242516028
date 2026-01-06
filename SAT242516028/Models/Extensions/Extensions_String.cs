namespace Extensions;

public static class StringExtensions
{
    public static string ToSafeString(this string? value)
    {
        return value ?? string.Empty;
    }
}