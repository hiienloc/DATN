using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DOAN4.Migrations
{
    /// <inheritdoc />
    public partial class AddRenameMinStockField : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "MinStockLevel",
                table: "Inventories",
                newName: "MinStock");

            migrationBuilder.AddColumn<bool>(
                name: "IsDelete",
                table: "Categories",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsDelete",
                table: "Categories");

            migrationBuilder.RenameColumn(
                name: "MinStock",
                table: "Inventories",
                newName: "MinStockLevel");
        }
    }
}
