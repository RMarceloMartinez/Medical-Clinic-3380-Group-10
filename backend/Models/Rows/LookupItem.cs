using System.Text.Json.Serialization;

namespace ClinicApi.Models;

public class LookupItem
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    // Only the doctors list fills this (visit fee); left out of the JSON when empty
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public decimal? Fee { get; set; }
}