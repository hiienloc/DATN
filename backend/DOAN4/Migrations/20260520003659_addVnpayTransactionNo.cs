using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DOAN4.Migrations
{
    /// <inheritdoc />
    public partial class addVnpayTransactionNo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "PaidAt",
                table: "Payments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VnpayBankCode",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VnpayResponseCode",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VnpayTransactionNo",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PaidAt",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "VnpayBankCode",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "VnpayResponseCode",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "VnpayTransactionNo",
                table: "Payments");
        }
    }
}
