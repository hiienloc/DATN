using DOAN4.Models;
using Microsoft.EntityFrameworkCore;

namespace DOAN4.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Role> Roles { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Inventory> Inventories { get; set; }
        public DbSet<InventoryTransaction> InventoryTransactions { get; set; }
        public DbSet<Package> Packages { get; set; }
        public DbSet<PackageItem> PackageItems { get; set; }
        public DbSet<Cart> Carts { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Forecast> Forecasts { get; set; }
        public DbSet<PaymentTransaction> PaymentTransactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ─── Role → User (1-n) ───────────────────────────────────────
            modelBuilder.Entity<User>()
                .HasOne(u => u.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(u => u.RoleId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── User → Order (1-n) ──────────────────────────────────────
            modelBuilder.Entity<Order>()
                .HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Cart>()
                .HasOne(c => c.User)
                .WithOne(u => u.Carts)
                .HasForeignKey<Cart>(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Order → Payment (1-1) ───────────────────────────────────
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Order)
                .WithOne(o => o.Payment)
                .HasForeignKey<Payment>(p => p.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Order → OrderItem (1-n) ─────────────────────────────────
            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Order)
                .WithMany(o => o.Items)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Package → OrderItem (1-n) ───────────────────────────────
            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Package)
                .WithMany(p => p.OrderItems)
                .HasForeignKey(oi => oi.PackageId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Cart → CartItem (1-n) ───────────────────────────────────
            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Cart)
                .WithMany(c => c.CartItems)
                .HasForeignKey(ci => ci.CartId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Package → CartItem (1-n) ────────────────────────────────
            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Package)
                .WithMany(p => p.CartItems)
                .HasForeignKey(ci => ci.PackageId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Package → PackageItem (1-n) ─────────────────────────────
            modelBuilder.Entity<PackageItem>()
                .HasOne(pi => pi.Package)
                .WithMany(p => p.PackageItems)
                .HasForeignKey(pi => pi.PackageId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Category → Product (1-n) ────────────────────────────────
            modelBuilder.Entity<Product>()
                .HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Product → PackageItem (1-n) 
            modelBuilder.Entity<PackageItem>()
                .HasOne(pi => pi.Product)
                .WithMany(p => p.PackageItems)
                .HasForeignKey(pi => pi.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Product → Inventory (1-1) 
            modelBuilder.Entity<Inventory>()
                .HasOne(i => i.Product)
                .WithOne(p => p.Inventory)
                .HasForeignKey<Inventory>(i => i.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Inventory → InventoryTransaction (1-n) ──────────────────
            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(it => it.Inventory)
                .WithMany(i => i.InventoryTransactions)
                .HasForeignKey(it => it.InventoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // ─── Package → InventoryTransaction (1-n, nullable) ──────────
            modelBuilder.Entity<InventoryTransaction>()
                .HasOne(it => it.Package)
                .WithMany(p => p.InventoryTransactions)
                .HasForeignKey(it => it.PackageId)
                .IsRequired(false)
                .OnDelete(DeleteBehavior.SetNull);

            // ─── Product → Forecast (1-n) ────────────────────────────────
            modelBuilder.Entity<Forecast>()
                .HasOne(f => f.Product)
                .WithMany(p => p.Forecasts)
                .HasForeignKey(f => f.ProductId)
                .OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();
            modelBuilder.Entity<PaymentTransaction>()
                .HasOne(i => i.Payment).WithMany(m => m.Transactions).HasForeignKey(f => f.PaymentId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}