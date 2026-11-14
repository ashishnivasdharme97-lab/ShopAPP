using System.ComponentModel.DataAnnotations;

namespace ShopAPI.Models;

public class Udhar
{
    public int Id { get; set; }

    [Range(1, int.MaxValue)]
    public int UserId { get; set; }

    [Required]
    [MaxLength(200)]
    public string CustomerName { get; set; } = string.Empty;

    [Range(typeof(decimal), "0.01", "9999999999999999.99")]
    public decimal Amount { get; set; }

    [Range(typeof(decimal), "0", "9999999999999999.99")]
    public decimal RemainingAmount { get; set; }

    public DateTime DueDate { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public bool IsPaid { get; set; }

    [Range(typeof(decimal), "0", "9999999999999999.99")]
    public decimal PaidAmount { get; set; }

    public DateTime CreatedAtUtc { get; set; }

    public DateTime? UpdatedAtUtc { get; set; }
}
