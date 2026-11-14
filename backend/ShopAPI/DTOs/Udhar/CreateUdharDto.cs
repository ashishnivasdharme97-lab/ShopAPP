using System.ComponentModel.DataAnnotations;

namespace ShopAPI.DTOs.Udhar;

public class CreateUdharDto
{
    [Range(1, int.MaxValue, ErrorMessage = "UserId must be greater than 0.")]
    public int UserId { get; set; }

    [Required(ErrorMessage = "CustomerName is required.")]
    [StringLength(200, ErrorMessage = "CustomerName cannot exceed 200 characters.")]
    public string CustomerName { get; set; } = string.Empty;

    [Range(typeof(decimal), "0.01", "9999999999999999.99",
        ErrorMessage = "Amount must be greater than 0.")]
    public decimal Amount { get; set; }

    [Range(typeof(decimal), "0", "9999999999999999.99",
        ErrorMessage = "RemainingAmount cannot be negative.")]
    public decimal RemainingAmount { get; set; }

    public DateTime DueDate { get; set; }

    [StringLength(1000, ErrorMessage = "Notes cannot exceed 1000 characters.")]
    public string? Notes { get; set; }

    public bool IsPaid { get; set; }

    [Range(typeof(decimal), "0", "9999999999999999.99",
        ErrorMessage = "PaidAmount cannot be negative.")]
    public decimal PaidAmount { get; set; }
}
