namespace ShopAPI.DTOs.Udhar;

public class UdharResponseDto
{
    public int Id { get; init; }
    public int UserId { get; init; }
    public string CustomerName { get; init; } = string.Empty;
    public decimal Amount { get; init; }
    public decimal RemainingAmount { get; init; }
    public DateTime DueDate { get; init; }
    public string? Notes { get; init; }
    public bool IsPaid { get; init; }
    public decimal PaidAmount { get; init; }
    public DateTime CreatedAtUtc { get; init; }
    public DateTime? UpdatedAtUtc { get; init; }

    public static UdharResponseDto FromEntity(Models.Udhar entity) => new()
    {
        Id = entity.Id,
        UserId = entity.UserId,
        CustomerName = entity.CustomerName,
        Amount = entity.Amount,
        RemainingAmount = entity.RemainingAmount,
        DueDate = entity.DueDate,
        Notes = entity.Notes,
        IsPaid = entity.IsPaid,
        PaidAmount = entity.PaidAmount,
        CreatedAtUtc = entity.CreatedAtUtc,
        UpdatedAtUtc = entity.UpdatedAtUtc
    };
}
