using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DOAN4.Migrations
{
    /// <inheritdoc />
    public partial class addShipmentPrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "ShipmentPrice",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ShipmentPrice",
                table: "Orders");
        }
    }
}
