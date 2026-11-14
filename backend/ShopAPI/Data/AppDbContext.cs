using Microsoft.EntityFrameworkCore;
using ShopAPI.Models;

namespace ShopAPI.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options)
    : DbContext(options)
{
    public DbSet<Udhar> Udhar { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Udhar>(entity =>
        {
            entity.ToTable("Udhar");
            entity.HasKey(item => item.Id);
            entity.Property(item => item.CustomerName)
                .HasMaxLength(200)
                .IsRequired();
            entity.Property(item => item.Amount).HasPrecision(18, 2);
            entity.Property(item => item.RemainingAmount).HasPrecision(18, 2);
            entity.Property(item => item.PaidAmount).HasPrecision(18, 2);
            entity.Property(item => item.Notes).HasMaxLength(1000);
            entity.HasIndex(item => item.UserId);
        });
    }
}
