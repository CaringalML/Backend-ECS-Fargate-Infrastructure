using Microsoft.EntityFrameworkCore;
using ProductApi.Models;

namespace ProductApi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Product entity
            modelBuilder.Entity<Product>()
                .HasKey(p => p.Id);
            
            modelBuilder.Entity<Product>()
                .Property(p => p.Name)
                .IsRequired()
                .HasMaxLength(100);
                
            modelBuilder.Entity<Product>()
                .Property(p => p.Description)
                .HasMaxLength(500);
                
            modelBuilder.Entity<Product>()
                .Property(p => p.Price)
                .HasPrecision(18, 2)
                .IsRequired();
        }
    }
}