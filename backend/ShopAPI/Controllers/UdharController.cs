using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopAPI.Data;
using ShopAPI.DTOs.Udhar;
using ShopAPI.Models;

namespace ShopAPI.Controllers;

[ApiController]
[Route("api/udhar")]
[Authorize]
public class UdharController(AppDbContext context) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<UdharResponseDto>> Create(
        CreateUdharDto dto,
        CancellationToken cancellationToken)
    {
        if (!IsAdmin() && GetCurrentUserId() != dto.UserId)
        {
            return Forbid();
        }

        var validationError = ValidateAmounts(
            dto.Amount, dto.RemainingAmount, dto.PaidAmount, dto.IsPaid);
        if (validationError is not null) return BadRequest(validationError);

        var entity = new Udhar
        {
            UserId = dto.UserId,
            CustomerName = dto.CustomerName.Trim(),
            Amount = dto.Amount,
            RemainingAmount = dto.RemainingAmount,
            DueDate = AsUtc(dto.DueDate),
            Notes = CleanNotes(dto.Notes),
            IsPaid = dto.IsPaid,
            PaidAmount = dto.PaidAmount,
            CreatedAtUtc = DateTime.UtcNow
        };

        context.Udhar.Add(entity);
        await context.SaveChangesAsync(cancellationToken);

        var response = UdharResponseDto.FromEntity(entity);
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, response);
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<IReadOnlyList<UdharResponseDto>>> GetAll(
        CancellationToken cancellationToken)
    {
        var records = await context.Udhar
            .AsNoTracking()
            .OrderByDescending(item => item.CreatedAtUtc)
            .ToListAsync(cancellationToken);

        return Ok(records.Select(UdharResponseDto.FromEntity).ToList());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<UdharResponseDto>> GetById(
        int id,
        CancellationToken cancellationToken)
    {
        var entry = await context.Udhar
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.Id == id, cancellationToken);

        if (entry is null || !CanAccess(entry.UserId))
        {
            return NotFound(new ProblemDetails
            {
                Status = StatusCodes.Status404NotFound,
                Title = "Udhar record not found."
            });
        }

        return Ok(UdharResponseDto.FromEntity(entry));
    }

    [HttpGet("user/{userId:int}")]
    public async Task<ActionResult<IReadOnlyList<UdharResponseDto>>> GetByUser(
        int userId,
        CancellationToken cancellationToken)
    {
        if (!IsAdmin() && GetCurrentUserId() != userId)
        {
            return Forbid();
        }

        var records = await context.Udhar
            .AsNoTracking()
            .Where(item => item.UserId == userId)
            .OrderByDescending(item => item.CreatedAtUtc)
            .ToListAsync(cancellationToken);

        return Ok(records.Select(UdharResponseDto.FromEntity).ToList());
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<UdharResponseDto>> Update(
        int id,
        UpdateUdharDto dto,
        CancellationToken cancellationToken)
    {
        var entry = await context.Udhar
            .FirstOrDefaultAsync(item => item.Id == id, cancellationToken);

        if (entry is null || !CanAccess(entry.UserId))
        {
            return NotFound(new ProblemDetails
            {
                Status = StatusCodes.Status404NotFound,
                Title = "Udhar record not found."
            });
        }

        var validationError = ValidateAmounts(
            dto.Amount, dto.RemainingAmount, dto.PaidAmount, dto.IsPaid);
        if (validationError is not null) return BadRequest(validationError);

        entry.CustomerName = dto.CustomerName.Trim();
        entry.Amount = dto.Amount;
        entry.RemainingAmount = dto.RemainingAmount;
        entry.DueDate = AsUtc(dto.DueDate);
        entry.Notes = CleanNotes(dto.Notes);
        entry.IsPaid = dto.IsPaid;
        entry.PaidAmount = dto.PaidAmount;
        entry.UpdatedAtUtc = DateTime.UtcNow;

        await context.SaveChangesAsync(cancellationToken);
        return Ok(UdharResponseDto.FromEntity(entry));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(
        int id,
        CancellationToken cancellationToken)
    {
        var entry = await context.Udhar
            .FirstOrDefaultAsync(item => item.Id == id, cancellationToken);

        if (entry is null || !CanAccess(entry.UserId))
        {
            return NotFound(new ProblemDetails
            {
                Status = StatusCodes.Status404NotFound,
                Title = "Udhar record not found."
            });
        }

        context.Udhar.Remove(entry);
        await context.SaveChangesAsync(cancellationToken);
        return NoContent();
    }

    private bool IsAdmin() => User.IsInRole("Admin");

    private bool CanAccess(int userId) =>
        IsAdmin() || GetCurrentUserId() == userId;

    private int? GetCurrentUserId()
    {
        var value = User.FindFirstValue("userId")
            ?? User.FindFirstValue("id")
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");
        return int.TryParse(value, out var userId) ? userId : null;
    }

    private ProblemDetails? ValidateAmounts(
        decimal amount,
        decimal remainingAmount,
        decimal paidAmount,
        bool isPaid)
    {
        if (isPaid && remainingAmount != 0)
        {
            return new ProblemDetails
            {
                Status = StatusCodes.Status400BadRequest,
                Title = "Invalid payment status.",
                Detail = "RemainingAmount must be 0 when IsPaid is true."
            };
        }

        if (paidAmount > amount)
        {
            return new ProblemDetails
            {
                Status = StatusCodes.Status400BadRequest,
                Title = "Invalid paid amount.",
                Detail = "PaidAmount cannot be greater than Amount."
            };
        }

        return null;
    }

    private static DateTime AsUtc(DateTime value) => value.Kind switch
    {
        DateTimeKind.Utc => value,
        DateTimeKind.Local => value.ToUniversalTime(),
        _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
    };

    private static string? CleanNotes(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
