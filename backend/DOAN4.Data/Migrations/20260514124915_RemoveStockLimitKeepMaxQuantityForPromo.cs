using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DOAN4.Migrations
{
    /// <inheritdoc />
    public partial class RemoveStockLimitKeepMaxQuantityForPromo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StockLimit",
                table: "Packages");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "StockLimit",
                table: "Packages",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);
        }
    }
}
