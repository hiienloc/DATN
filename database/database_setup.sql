IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Categories] (
    [CategoryId] int NOT NULL IDENTITY,
    [CategoryName] nvarchar(50) NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY ([CategoryId])
);
GO

CREATE TABLE [Packages] (
    [PackageId] int NOT NULL IDENTITY,
    [PackageCode] nvarchar(50) NOT NULL,
    [PackageName] nvarchar(50) NOT NULL,
    [ImageUrl] nvarchar(max) NOT NULL,
    [Description] nvarchar(255) NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [StartDate] datetime2 NOT NULL,
    [EndDate] datetime2 NOT NULL,
    [Discount] decimal(18,2) NOT NULL,
    [MaxQuantity] int NOT NULL,
    [StockLimit] decimal(18,2) NOT NULL,
    [PackageType] nvarchar(max) NOT NULL,
    [RowVersion] rowversion NOT NULL,
    [IsDeleted] bit NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Packages] PRIMARY KEY ([PackageId])
);
GO

CREATE TABLE [Roles] (
    [RoleId] int NOT NULL IDENTITY,
    [RoleName] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([RoleId])
);
GO

CREATE TABLE [Products] (
    [ProductId] int NOT NULL IDENTITY,
    [ProductCode] nvarchar(50) NOT NULL,
    [ProductName] nvarchar(100) NOT NULL,
    [Unit] nvarchar(50) NOT NULL,
    [IsDeleted] bit NOT NULL,
    [IsActive] bit NOT NULL,
    [CategoryId] int NOT NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([ProductId]),
    CONSTRAINT [FK_Products_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([CategoryId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Users] (
    [UserId] int NOT NULL IDENTITY,
    [FullName] nvarchar(100) NOT NULL,
    [Email] nvarchar(100) NOT NULL,
    [Password] nvarchar(20) NOT NULL,
    [PhoneNumber] nvarchar(15) NOT NULL,
    [CreateAt] datetime2 NOT NULL,
    [IsActive] bit NOT NULL,
    [IsDeleted] bit NOT NULL,
    [RoleId] int NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([UserId]),
    CONSTRAINT [FK_Users_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([RoleId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Forecasts] (
    [ForecastId] int NOT NULL IDENTITY,
    [ProductId] int NOT NULL,
    [ForecastType] nvarchar(max) NOT NULL,
    [AvgDailySales] decimal(18,2) NOT NULL,
    [PredictQuantity] decimal(18,2) NOT NULL,
    [SuggestReStock] decimal(18,2) NOT NULL,
    [CurrentStock] decimal(18,2) NOT NULL,
    [ForecastDate] datetime2 NOT NULL,
    [GeneratedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Forecasts] PRIMARY KEY ([ForecastId]),
    CONSTRAINT [FK_Forecasts_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Inventories] (
    [InventoryId] int NOT NULL IDENTITY,
    [ProductId] int NOT NULL,
    [QtyInStock] decimal(18,2) NOT NULL,
    [MinStockLevel] decimal(18,2) NOT NULL,
    [LastUpdated] datetime2 NOT NULL,
    CONSTRAINT [PK_Inventories] PRIMARY KEY ([InventoryId]),
    CONSTRAINT [FK_Inventories_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [PackageItems] (
    [PackageItemId] int NOT NULL IDENTITY,
    [PackageId] int NOT NULL,
    [ProductId] int NOT NULL,
    [PackageQty] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_PackageItems] PRIMARY KEY ([PackageItemId]),
    CONSTRAINT [FK_PackageItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_PackageItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Carts] (
    [CartId] int NOT NULL IDENTITY,
    [TotalPrice] decimal(18,2) NOT NULL,
    [UserId] int NOT NULL,
    CONSTRAINT [PK_Carts] PRIMARY KEY ([CartId]),
    CONSTRAINT [FK_Carts_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([UserId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Orders] (
    [OrderId] int NOT NULL IDENTITY,
    [OrderCode] nvarchar(max) NOT NULL,
    [ReceiveName] nvarchar(50) NOT NULL,
    [ReceivePhone] nvarchar(15) NOT NULL,
    [ReceiveAddress] nvarchar(255) NOT NULL,
    [OrderDate] datetime2 NOT NULL,
    [OrderStatus] nvarchar(max) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [UserId] int NOT NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([OrderId]),
    CONSTRAINT [FK_Orders_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([UserId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [InventoryTransactions] (
    [TransactionId] int NOT NULL IDENTITY,
    [InventoryId] int NOT NULL,
    [PackageId] int NULL,
    [QuantityChange] decimal(18,2) NOT NULL,
    [Note] nvarchar(max) NOT NULL,
    [TransactionDate] datetime2 NOT NULL,
    [TransactionType] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_InventoryTransactions] PRIMARY KEY ([TransactionId]),
    CONSTRAINT [FK_InventoryTransactions_Inventories_InventoryId] FOREIGN KEY ([InventoryId]) REFERENCES [Inventories] ([InventoryId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_InventoryTransactions_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE SET NULL
);
GO

CREATE TABLE [CartItems] (
    [CartItemId] int NOT NULL IDENTITY,
    [CartId] int NOT NULL,
    [CartQuantity] int NOT NULL,
    [CartPrice] decimal(18,2) NOT NULL,
    [PackageId] int NOT NULL,
    CONSTRAINT [PK_CartItems] PRIMARY KEY ([CartItemId]),
    CONSTRAINT [FK_CartItems_Carts_CartId] FOREIGN KEY ([CartId]) REFERENCES [Carts] ([CartId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_CartItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [OrderItems] (
    [OrderItemId] int NOT NULL IDENTITY,
    [OrderId] int NOT NULL,
    [PackageId] int NOT NULL,
    [OrderPrice] decimal(18,2) NOT NULL,
    [OrderQuantity] int NOT NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([OrderItemId]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([OrderId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_OrderItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Payments] (
    [PaymentId] int NOT NULL IDENTITY,
    [PaymentMethod] nvarchar(max) NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PaymentStatus] nvarchar(max) NOT NULL,
    [OrderId] int NOT NULL,
    CONSTRAINT [PK_Payments] PRIMARY KEY ([PaymentId]),
    CONSTRAINT [FK_Payments_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([OrderId]) ON DELETE NO ACTION
);
GO

CREATE INDEX [IX_CartItems_CartId] ON [CartItems] ([CartId]);
GO

CREATE INDEX [IX_CartItems_PackageId] ON [CartItems] ([PackageId]);
GO

CREATE UNIQUE INDEX [IX_Carts_UserId] ON [Carts] ([UserId]);
GO

CREATE INDEX [IX_Forecasts_ProductId] ON [Forecasts] ([ProductId]);
GO

CREATE UNIQUE INDEX [IX_Inventories_ProductId] ON [Inventories] ([ProductId]);
GO

CREATE INDEX [IX_InventoryTransactions_InventoryId] ON [InventoryTransactions] ([InventoryId]);
GO

CREATE INDEX [IX_InventoryTransactions_PackageId] ON [InventoryTransactions] ([PackageId]);
GO

CREATE INDEX [IX_OrderItems_OrderId] ON [OrderItems] ([OrderId]);
GO

CREATE INDEX [IX_OrderItems_PackageId] ON [OrderItems] ([PackageId]);
GO

CREATE INDEX [IX_Orders_UserId] ON [Orders] ([UserId]);
GO

CREATE INDEX [IX_PackageItems_PackageId] ON [PackageItems] ([PackageId]);
GO

CREATE INDEX [IX_PackageItems_ProductId] ON [PackageItems] ([ProductId]);
GO

CREATE UNIQUE INDEX [IX_Payments_OrderId] ON [Payments] ([OrderId]);
GO

CREATE INDEX [IX_Products_CategoryId] ON [Products] ([CategoryId]);
GO

CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]);
GO

CREATE INDEX [IX_Users_RoleId] ON [Users] ([RoleId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260511082309_createon', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Packages]') AND [c].[name] = N'PackageType');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Packages] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Packages] DROP COLUMN [PackageType];
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260512095442_RemovePackageTypeFromPackage', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Packages]') AND [c].[name] = N'StockLimit');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Packages] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Packages] DROP COLUMN [StockLimit];
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260514124915_RemoveStockLimitKeepMaxQuantityForPromo', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE [Orders] ADD [ShipmentPrice] decimal(18,2) NOT NULL DEFAULT 0.0;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260515144655_addShipmentPrice', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

EXEC sp_rename N'[Inventories].[MinStockLevel]', N'MinStock', N'COLUMN';
GO

ALTER TABLE [Categories] ADD [IsDelete] bit NOT NULL DEFAULT CAST(0 AS bit);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260517015809_AddRenameMinStockField', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Products]') AND [c].[name] = N'IsDeleted');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Products] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Products] DROP COLUMN [IsDeleted];
GO

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Packages]') AND [c].[name] = N'IsDeleted');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Packages] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [Packages] DROP COLUMN [IsDeleted];
GO

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categories]') AND [c].[name] = N'IsDelete');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Categories] DROP CONSTRAINT [' + @var4 + '];');
ALTER TABLE [Categories] DROP COLUMN [IsDelete];
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260517071727_RemoveIsDeleted', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE [Payments] ADD [PaidAt] datetime2 NULL;
GO

ALTER TABLE [Payments] ADD [VnpayBankCode] nvarchar(max) NULL;
GO

ALTER TABLE [Payments] ADD [VnpayResponseCode] nvarchar(max) NULL;
GO

ALTER TABLE [Payments] ADD [VnpayTransactionNo] nvarchar(max) NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260520003659_addVnpayTransactionNo', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'VnpayBankCode');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var5 + '];');
ALTER TABLE [Payments] DROP COLUMN [VnpayBankCode];
GO

DECLARE @var6 sysname;
SELECT @var6 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'VnpayResponseCode');
IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var6 + '];');
ALTER TABLE [Payments] DROP COLUMN [VnpayResponseCode];
GO

DECLARE @var7 sysname;
SELECT @var7 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'VnpayTransactionNo');
IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var7 + '];');
ALTER TABLE [Payments] DROP COLUMN [VnpayTransactionNo];
GO

EXEC sp_rename N'[Payments].[PaidAt]', N'UpdatedAt', N'COLUMN';
GO

ALTER TABLE [Payments] ADD [CreatedAt] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';
GO

CREATE TABLE [PaymentTransactions] (
    [TransactionId] int NOT NULL IDENTITY,
    [PaymentId] int NOT NULL,
    [VnpayTxnRef] nvarchar(max) NULL,
    [TransactionNo] nvarchar(max) NULL,
    [BankCode] nvarchar(max) NULL,
    [ResponseCode] nvarchar(max) NULL,
    [Status] nvarchar(max) NOT NULL,
    [TransactionDate] datetime2 NOT NULL,
    CONSTRAINT [PK_PaymentTransactions] PRIMARY KEY ([TransactionId]),
    CONSTRAINT [FK_PaymentTransactions_Payments_PaymentId] FOREIGN KEY ([PaymentId]) REFERENCES [Payments] ([PaymentId]) ON DELETE NO ACTION
);
GO

CREATE INDEX [IX_PaymentTransactions_PaymentId] ON [PaymentTransactions] ([PaymentId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260521001712_addPaymentTransaction', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531123214_AddInventoryRowVersion', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var8 sysname;
SELECT @var8 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Roles]') AND [c].[name] = N'RoleName');
IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [Roles] DROP CONSTRAINT [' + @var8 + '];');
ALTER TABLE [Roles] ALTER COLUMN [RoleName] nvarchar(20) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531133918_AddRoleNameLengthConstraint', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var9 sysname;
SELECT @var9 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'PhoneNumber');
IF @var9 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var9 + '];');
ALTER TABLE [Users] ALTER COLUMN [PhoneNumber] nvarchar(10) NOT NULL;
GO

DECLARE @var10 sysname;
SELECT @var10 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ReceivePhone');
IF @var10 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var10 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ReceivePhone] nvarchar(10) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531141020_UpdatePhoneNumberLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var11 sysname;
SELECT @var11 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'PhoneNumber');
IF @var11 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var11 + '];');
ALTER TABLE [Users] ALTER COLUMN [PhoneNumber] varchar(10) NOT NULL;
GO

DECLARE @var12 sysname;
SELECT @var12 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ReceivePhone');
IF @var12 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var12 + '];');
ALTER TABLE [Orders] ALTER COLUMN [ReceivePhone] varchar(10) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531141150_ChangePhoneToVarchar', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var13 sysname;
SELECT @var13 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'OrderStatus');
IF @var13 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var13 + '];');
ALTER TABLE [Orders] ALTER COLUMN [OrderStatus] nvarchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531142043_UpdateOrderStatusLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var14 sysname;
SELECT @var14 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Packages]') AND [c].[name] = N'ImageUrl');
IF @var14 IS NOT NULL EXEC(N'ALTER TABLE [Packages] DROP CONSTRAINT [' + @var14 + '];');
ALTER TABLE [Packages] ALTER COLUMN [ImageUrl] varchar(255) NOT NULL;
GO

DECLARE @var15 sysname;
SELECT @var15 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'OrderCode');
IF @var15 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var15 + '];');
ALTER TABLE [Orders] ALTER COLUMN [OrderCode] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531142307_UpdateOrderCodeAndImageUrl', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var16 sysname;
SELECT @var16 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[InventoryTransactions]') AND [c].[name] = N'Note');
IF @var16 IS NOT NULL EXEC(N'ALTER TABLE [InventoryTransactions] DROP CONSTRAINT [' + @var16 + '];');
ALTER TABLE [InventoryTransactions] ALTER COLUMN [Note] nvarchar(100) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531142931_UpdateInventoryTransactionNoteLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var17 sysname;
SELECT @var17 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[InventoryTransactions]') AND [c].[name] = N'Note');
IF @var17 IS NOT NULL EXEC(N'ALTER TABLE [InventoryTransactions] DROP CONSTRAINT [' + @var17 + '];');
ALTER TABLE [InventoryTransactions] ALTER COLUMN [Note] varchar(100) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531143251_ChangeNoteToVarchar', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var18 sysname;
SELECT @var18 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'PaymentMethod');
IF @var18 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var18 + '];');
ALTER TABLE [Payments] ALTER COLUMN [PaymentMethod] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531143528_UpdatePaymentMethodLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var19 sysname;
SELECT @var19 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'PaymentStatus');
IF @var19 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var19 + '];');
ALTER TABLE [Payments] ALTER COLUMN [PaymentStatus] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531143611_UpdatePaymentStatusLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var20 sysname;
SELECT @var20 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PaymentTransactions]') AND [c].[name] = N'Status');
IF @var20 IS NOT NULL EXEC(N'ALTER TABLE [PaymentTransactions] DROP CONSTRAINT [' + @var20 + '];');
ALTER TABLE [PaymentTransactions] ALTER COLUMN [Status] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531143844_UpdatePaymentTransactionStatusLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var21 sysname;
SELECT @var21 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PaymentTransactions]') AND [c].[name] = N'VnpayTxnRef');
IF @var21 IS NOT NULL EXEC(N'ALTER TABLE [PaymentTransactions] DROP CONSTRAINT [' + @var21 + '];');
ALTER TABLE [PaymentTransactions] ALTER COLUMN [VnpayTxnRef] varchar(50) NULL;
GO

DECLARE @var22 sysname;
SELECT @var22 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PaymentTransactions]') AND [c].[name] = N'TransactionNo');
IF @var22 IS NOT NULL EXEC(N'ALTER TABLE [PaymentTransactions] DROP CONSTRAINT [' + @var22 + '];');
ALTER TABLE [PaymentTransactions] ALTER COLUMN [TransactionNo] varchar(50) NULL;
GO

DECLARE @var23 sysname;
SELECT @var23 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PaymentTransactions]') AND [c].[name] = N'ResponseCode');
IF @var23 IS NOT NULL EXEC(N'ALTER TABLE [PaymentTransactions] DROP CONSTRAINT [' + @var23 + '];');
ALTER TABLE [PaymentTransactions] ALTER COLUMN [ResponseCode] varchar(10) NULL;
GO

DECLARE @var24 sysname;
SELECT @var24 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PaymentTransactions]') AND [c].[name] = N'BankCode');
IF @var24 IS NOT NULL EXEC(N'ALTER TABLE [PaymentTransactions] DROP CONSTRAINT [' + @var24 + '];');
ALTER TABLE [PaymentTransactions] ALTER COLUMN [BankCode] varchar(20) NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531144003_UpdateVNPayTransactionFields', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var25 sysname;
SELECT @var25 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Forecasts]') AND [c].[name] = N'ForecastType');
IF @var25 IS NOT NULL EXEC(N'ALTER TABLE [Forecasts] DROP CONSTRAINT [' + @var25 + '];');
ALTER TABLE [Forecasts] ALTER COLUMN [ForecastType] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531144312_UpdateForecastTypeLength', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var26 sysname;
SELECT @var26 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Password');
IF @var26 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var26 + '];');
ALTER TABLE [Users] ALTER COLUMN [Password] varchar(255) NOT NULL;
GO

DROP INDEX [IX_Users_Email] ON [Users];
DECLARE @var27 sysname;
SELECT @var27 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Email');
IF @var27 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var27 + '];');
ALTER TABLE [Users] ALTER COLUMN [Email] varchar(100) NOT NULL;
CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]);
GO

DECLARE @var28 sysname;
SELECT @var28 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'OrderStatus');
IF @var28 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var28 + '];');
ALTER TABLE [Orders] ALTER COLUMN [OrderStatus] varchar(50) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531144935_ChangeRequiredFieldsToVarchar', N'8.0.11');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var29 sysname;
SELECT @var29 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'OrderStatus');
IF @var29 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var29 + '];');
ALTER TABLE [Orders] ALTER COLUMN [OrderStatus] nvarchar(50) NOT NULL;
GO

DECLARE @var30 sysname;
SELECT @var30 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[InventoryTransactions]') AND [c].[name] = N'Note');
IF @var30 IS NOT NULL EXEC(N'ALTER TABLE [InventoryTransactions] DROP CONSTRAINT [' + @var30 + '];');
ALTER TABLE [InventoryTransactions] ALTER COLUMN [Note] nvarchar(100) NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260531151752_RevertOrderStatusAndNoteToNvarchar', N'8.0.11');
GO

COMMIT;
GO

-- DATABASE DATA SEED SCRIPT FOR SOMEE
-- Generated on 06/02/2026 11:37:21

-- Data for table Roles
SET IDENTITY_INSERT [Roles] ON;
INSERT INTO [Roles] ([RoleId], [RoleName]) VALUES (1, N'Admin');
INSERT INTO [Roles] ([RoleId], [RoleName]) VALUES (2, N'Customer');
SET IDENTITY_INSERT [Roles] OFF;

-- Data for table Users
SET IDENTITY_INSERT [Users] ON;
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (1, N'Admin', N'admin@gmail.com', N'66c9248d1d2d4ccf7f9367341faa8f4f6c1f503fc2043285caa86c6b9bf26488', N'0398892300', '2026-05-05 00:00:00.000', 1, 1);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2, N'Quang Ðô', N'nguyendo@gmail.com', N'4817f7bfae4d77a09c7b22587394dd60a7b0ccbd8d7922494dafbfda428ebd9c', N'0972345678', '2026-05-13 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (3, N'Nguy?n An', N'nguyenan@gmail.com', N'c4202834207d1c617aa5a132d6b875351f68ed18e7e3bd5ce071dc39c6dd5ba1', N'0972395678', '2026-05-14 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (1002, N'Nguy?n Th? An', N'annguyen2004@gmail.com', N'19c55ff4f8812284519366a41feef83ac082cd28106088d53ee8f8ac3f4028e5', N'0365331333', '2026-05-14 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (1003, N'L?c Hiên', N'lochien2003@gmail.com', N'66c9248d1d2d4ccf7f9367341faa8f4f6c1f503fc2043285caa86c6b9bf26488', N'0989431789', '2026-05-14 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2003, N'Ðào Tuoi', N'daotuoi@gmail.com', N'8214455045051f83e890360f276f5e3872dccafaf2545ca23ef3c6d8929075f1', N'0989767558', '2026-05-14 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2004, N'Nguy?n Minh Quang', N'quangnguyen2004@gmail.com', N'41c8f9b4df6e9e3fc16cfdb745e0ba72d9c5b08b0d56f9d6b01f36162b81f062', N'0912890113', '2026-05-15 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2005, N'Nguy?n Chi', N'chichi2004@gmail.com', N'4bae16b14175e948c85ee1ece8424e4fdd3b55412f1fe32419c1a03c575b44d1', N'0966771892', '2026-05-15 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2006, N'Hoàng Chi', N'chihoang2003@gmail.com', N'2dacbf4b132c3d73b18298d48bba05e1b97f48083814f9a06161fe848428f89e', N'0967456454', '2026-05-16 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2007, N'Tri?u M?nh Huy', N'huytrieu2003@gmail.com', N'67263d0f6457ce240f63146fddcc3e2d60498e71344d1d20f569d730f1a1d833', N'0912789569', '0001-01-01 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2008, N'Nhung Nguy?n', N'nhung@gmail.com', N'38ef550fff006d265f34be38e984fb4d4568737682732c81465d3853c9cdecba', N'0389141982', '0001-01-01 00:00:00.000', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2009, N'Nguy?n Van An', N'vanan@gmail.com', N'd9b2cab475c150a32e5e85e35efe5853f66fe7238c309bbb48f7ba9618e9fc30', N'0912567641', '2026-05-18 06:01:38.574', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2010, N'Loc Hien', N'lochien1112@gmail.com', N'66c9248d1d2d4ccf7f9367341faa8f4f6c1f503fc2043285caa86c6b9bf26488', N'0253313339', '2026-05-23 21:10:38.377', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2011, N'Hoàng Son', N'sonhoang@gmail.com', N'1fc2a88f24ec5f1c9ebaab676e74f7ad3d30ff9b7732513042e3e44aba9ad0c3', N'0914345567', '2026-05-27 22:34:36.930', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2012, N'Ph?m Th? Anh', N'theanh2004@gmail.com', N'04089a78a0cb54be1f33f024a2f37cbd893ac5a0e420aaf78d4e7a079ab3621b', N'0909890123', '2026-05-28 17:41:22.770', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2013, N'La Mai Anh', N'maianh@gmail.com', N'8f59071e8e2b686c1bc150bbbe27db8e5b9eeae5cc68df9e737301881dd17310', N'0366676689', '2026-05-28 17:55:24.676', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2014, N'Hoàng Ng?c B?ng', N'banghoang2003@gmail.com', N'ca247aeca8c2e0164959fc8e572e580bdf3f5b0f98653962175af4827b32fbe7', N'0989431725', '2026-05-28 18:23:44.216', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2015, N'L?c Thuong', N'locthuong93@gmail.com', N'987391d2066507edf07011039fb13f79d22d9ae7f04147617877d495331a7b27', N'0366566599', '2026-05-28 18:48:36.340', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2016, N'Tr?n Duy', N'duyduy2004@gmail.com', N'70ff3bace8b9ec523866208604b0a5ca89fd3ee067be65a273383b066d026ff7', N'0912234556', '2026-05-28 19:05:20.457', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2017, N'Tr?n Van Minh', N'vanminh2003@gmail.com', N'9ccd7ac8d9f848958bfc444a4c1cf615efe5641e685a97f9dce580dab4f766ad', N'0398892300', '2026-05-30 16:24:42.435', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2018, N'Hoàng Thanh H?i', N'thanhhai@gmail.com', N'c2d90ea60e5fe2e27ee5fdbc08f2a7d10948c9482c34122579f6863a5fb1d87e', N'0189898999', '2026-05-31 19:05:44.867', 1, 2);
INSERT INTO [Users] ([UserId], [FullName], [Email], [Password], [PhoneNumber], [CreateAt], [IsActive], [RoleId]) VALUES (2019, N'Hoàng Th? Phuong', N'hoangphuong@gmail.com', N'19f18c6b5924123fff893d0a477e472df5fc9cc2cd4fd5676e8fdf3d53aa0b95', N'0387500678', '2026-05-31 19:16:06.882', 1, 2);
SET IDENTITY_INSERT [Users] OFF;

-- Data for table Categories
SET IDENTITY_INSERT [Categories] ON;
INSERT INTO [Categories] ([CategoryId], [CategoryName], [IsActive]) VALUES (1, N'N?m', 1);
INSERT INTO [Categories] ([CategoryId], [CategoryName], [IsActive]) VALUES (2, N'Rau c?', 1);
INSERT INTO [Categories] ([CategoryId], [CategoryName], [IsActive]) VALUES (1002, N'Gia v?', 1);
INSERT INTO [Categories] ([CategoryId], [CategoryName], [IsActive]) VALUES (1003, N'Hoa qu?', 1);
SET IDENTITY_INSERT [Categories] OFF;

-- Data for table Products
SET IDENTITY_INSERT [Products] ON;
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1, N'MN001', N'Cà R?t', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (2, N'DC120', N'Dua Chu?t', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (3, N'CM223', N'Cà Chua', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (4, N'SP123', N'Chu?i', N'n?i', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (5, N'SP231', N'Táo Ð?', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (6, N'SP0456', N'Hành lá', N'kg', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (7, N'SP789', N'Cà Tím', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (8, N'SP900', N'Ngô Ng?t', N'b?p', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (9, N'SP890', N'Mu?p Thom', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (10, N'XL012', N'Xoài', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (11, N'KJF90', N'Khoai  Lang', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (12, N'MN899', N'Bí Ð?', N'qu?', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (13, N'LTT789', N'Rau mu?ng', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (14, N'NM897', N'N?m huong', N'gam', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (15, N'TLP90', N'N?m kim châm', N'túi', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (16, N'GHJ22', N'Ð? Que', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (17, N'GV100', N'T?i Khô', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (18, N'GHJ', N'Rau c?n tây', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (19, N'GHT22', N'Khoai Môn', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (20, N'TLJ99', N'Su Su', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (21, N'KLI21', N'Súp lo', N'cây', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (22, N'LKM', N'Su hào', N'c?', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (23, N'HKT123', N'Dâu tây', N'h?p', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (24, N'TQ123', N'Khoai tây', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (25, N'TL120', N'Qu? khô', N'gam', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (26, N'FGH321', N'H?i khô', N'gam', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (27, N'FDS12', N'N?m dùi gà', N'túi', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (28, N'GV901', N'Hành khô', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1004, N'KTL12', N'B?p C?i', N'cái', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1005, N'MK768', N'G?ng', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1006, N'TML129', N'Cây S?', N'cây', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1007, N'GV890', N'Ngh?', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1008, N'GHK98', N'Rau Xà Lách', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1009, N'FF167', N'Ð?u Hà Lan', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1010, N'OT001', N'?t Chuông Ð?', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1011, N'OT002', N'?t S?ng', N'kg', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1012, N'HL910', N'Hành tây', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1013, N'MN909', N'Giá Ð?', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1014, N'TKA178', N'Cam ', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1015, N'GR090', N'Nho', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1016, N'ASH', N'Lê', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1017, N'AWS', N'Bu?i', N'qu?', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1018, N'JGQ89', N'Quýt', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1019, N'WAS', N'Mít', N'qu?', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1020, N'KH123', N'M?n', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1021, N'RTA11', N'C?i thìa', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1022, N'RAM13', N'Chanh', N'qu?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1023, N'RAM14', N'Qu?t', N'qu?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1024, N'SAK', N'Ð?u R?ng', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1025, N'MAM12', N'M?ng Toi', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1026, N'ASK68', N'C?i Xoong', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1027, N'ASJ15', N'C?i Xoan', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1028, N'GKR18', N'C?i Bó Xôi', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1029, N'ASK09', N'Rau D?n', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1030, N'QTR90', N'C? D?n', N'c?', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1031, N'MÐ221', N'Mu?p Ð?ng', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1032, N'AKM55', N'Chôm Chôm', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1033, N'WSQ11', N'Dua H?u', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1034, N'REW89', N'Dua Lu?i', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1035, N'KJH89', N'Táo Mèo', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1036, N'AWW23', N'Qu? Bo', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1037, N'QKL12', N'Bí Xanh', N'qu?', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1038, N'KFG55', N'Bí Ngòi', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1039, N'CB123', N'Ngô N?p', N'b?p', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1040, N'CB234', N'Rau Ngót', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1041, N'FF224', N'C? C?i Tr?ng', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1042, N'SW456', N'Ri?ng', N'c?', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1043, N'SWK22', N'Khoai M?', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1044, N'ASK89', N'C? Sen', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1045, N'AAA18', N'Cà Pháo', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1046, N'KHM90', N'Bông Atiso', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1047, N'DD226', N'Ðu Ð?', N'qu?', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1048, N'LJS99', N'Tiá Tô', N'bó', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1049, N'TL900', N'Thì Là', N'bó', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1050, N'KSA00', N'D?a', N'qu?', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1051, N'LL003', N'C?i Ng?ng', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1052, N'WWW99', N'Rau Má', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1053, N'ZXA88', N'Thanh Long', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1054, N'M2003', N'Chanh Dây', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1055, N'BH890', N'Kh?', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1056, N'LKL45', N'Tiêu Xanh', N'kg', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1057, N'RM001', N'Rau Mùi Tàu', N'bó', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1058, N'RM002', N'Rau H?', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1059, N'KKT90', N'Rau Bí', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1060, N'HQ200', N'Qu? Cóc', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1061, N'HQ900', N'Qu? H?ng', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1062, N'ALK00', N'Qu? Roi', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1063, N'OKL56', N'?t Chuông Vàng', N'kg', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1064, N'FG003', N'Rau Kinh Gi?i', N'bó', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1065, N'NM900', N'N?m Rom', N'túi', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1066, N'NM564', N'N?m Sò', N'túi', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1067, N'RCX01', N'Rau C?i Xanh', N'bó', 1, 2);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1068, N'MC011', N'Mang C?t', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1069, N'HQ001', N'Nhãn ', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1070, N'SR211', N'S?u Riêng', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1071, N'QN211', N'Mãn C?u', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1072, N'MD121', N'Na', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1073, N'HD112', N'H?t Ði?u', N'kg', 1, 1002);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1074, N'HX100', N'H?ng Xiêm', N'kg', 1, 1003);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1075, N'NM', N'N?m M?', N'túi', 1, 1);
INSERT INTO [Products] ([ProductId], [ProductCode], [ProductName], [Unit], [IsActive], [CategoryId]) VALUES (1076, N'NBG01', N'N?m Bào Ngu', N'túi', 1, 1);
SET IDENTITY_INSERT [Products] OFF;

-- Data for table Inventories
SET IDENTITY_INSERT [Inventories] ON;
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1, 1, 79.50, 5.00, '2026-05-31 22:42:21.075');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (2, 2, 52.70, 5.00, '2026-05-28 19:14:45.131');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (3, 3, 18.90, 5.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (4, 4, 7.00, 5.00, '2026-05-31 22:42:21.231');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (5, 5, 16.00, 5.00, '2026-05-28 19:15:25.369');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (6, 6, 4.00, 5.00, '2026-05-31 22:42:21.114');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (7, 9, 30.50, 5.00, '2026-05-31 19:00:23.472');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (8, 17, 23.00, 5.00, '2026-05-31 22:42:21.058');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (9, 12, 10.50, 5.00, '2026-05-31 22:42:20.807');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (10, 14, 15.00, 5.00, '2026-05-31 22:42:21.017');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (11, 8, 27.00, 5.00, '2026-05-31 19:07:04.960');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (12, 23, 16.00, 5.00, '2026-05-28 18:22:23.632');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (13, 19, 81.00, 5.00, '2026-05-31 19:07:04.477');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (14, 21, 2.00, 5.00, '2026-05-31 22:42:21.218');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (15, 13, 22.00, 5.00, '2026-05-31 22:42:21.037');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (16, 11, 9.50, 5.00, '2026-05-31 19:00:23.896');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (17, 26, 989.00, 5.00, '2026-05-28 18:51:25.490');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (18, 24, 6.00, 5.00, '2026-05-31 22:42:21.093');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (19, 15, 90.00, 5.00, '2026-05-31 19:07:04.873');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (20, 28, 71.00, 0.00, '2026-05-31 19:00:24.650');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (21, 10, 6.50, 5.00, '2026-05-30 16:26:52.224');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1005, 27, 79.00, 5.00, '2026-05-31 19:07:04.940');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1006, 7, 47.00, 3.00, '2026-05-31 19:07:04.634');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1007, 16, 2.00, 4.00, '2026-05-31 19:00:25.161');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1008, 18, 13.00, 2.00, '2026-05-28 19:14:10.424');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1009, 20, 137.00, 4.00, '2026-05-31 22:33:43.176');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1010, 22, 75.00, 5.00, '2026-05-31 22:33:43.243');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1011, 25, 25.00, 5.00, '2026-05-15 15:39:28.935');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1012, 1004, 12.00, 3.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1013, 1008, 23.00, 1.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1014, 1005, 67.00, 3.00, '2026-05-28 19:14:10.325');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1015, 1006, 55.00, 3.00, '2026-05-15 16:03:10.160');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1016, 1007, 25.00, 4.00, '2026-05-31 19:00:24.618');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1017, 1009, 40.50, 2.50, '2026-05-31 19:07:04.605');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1018, 1010, 36.00, 2.00, '2026-05-31 19:00:23.376');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1019, 1011, 18.10, 9.00, '2026-05-31 19:07:04.751');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1020, 1013, 53.50, 2.50, '2026-05-31 19:00:23.693');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1021, 1012, 90.00, 3.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1022, 1021, 21.00, 8.00, '2026-05-31 19:00:26.242');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1023, 1014, 31.00, 5.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1024, 1015, 6.00, 4.00, '2026-05-31 19:00:25.413');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1025, 1016, 40.00, 3.00, '2026-05-30 16:28:02.549');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1026, 1017, 31.00, 3.00, '2026-05-28 17:40:40.911');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1027, 1018, 15.00, 3.00, '2026-05-16 08:25:17.853');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1028, 1019, 11.00, 3.00, '2026-05-28 17:40:40.937');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1029, 1020, 20.00, 3.00, '2026-05-30 16:28:02.131');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1030, 1024, 10.00, 5.00, '2026-05-31 19:00:25.996');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1031, 1025, 36.00, 3.00, '2026-05-31 22:42:21.205');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1032, 1026, 7.00, 3.00, '2026-05-29 17:52:38.550');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1033, 1027, 27.00, 2.00, '2026-05-31 19:00:26.028');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1034, 1028, 26.00, 3.00, '2026-05-31 19:00:26.312');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1035, 1029, 12.00, 4.00, '2026-05-31 22:42:21.244');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1036, 1030, 35.20, 5.00, '2026-05-31 19:00:26.278');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1037, 1031, 21.50, 2.50, '2026-05-30 16:28:01.859');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1038, 1022, 9.00, 3.00, '2026-05-28 19:14:10.468');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1039, 1023, 20.00, 3.00, '2026-05-16 14:34:54.922');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1040, 1035, 38.00, 2.00, '2026-05-31 19:00:25.325');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1041, 1032, 37.50, 5.00, '2026-05-31 19:00:25.448');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1042, 1033, 89.50, 3.50, '2026-05-31 19:00:24.979');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1043, 1034, 19.50, 2.50, '2026-05-31 19:00:25.492');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1044, 1036, 77.50, 2.50, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1045, 1037, 9.50, 3.50, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1046, 1038, 8.00, 3.00, '2026-05-31 19:00:26.097');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1047, 1039, 73.00, 2.00, '2026-05-31 22:42:21.191');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1048, 1040, 28.00, 3.00, '2026-05-31 22:42:21.132');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1049, 1041, 19.90, 1.00, '2026-05-29 17:52:38.563');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1050, 1043, 35.00, 2.50, '2026-05-16 15:35:37.637');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1051, 1044, 38.50, 3.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1052, 1045, 13.50, 2.50, '2026-05-31 22:42:21.178');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1053, 1046, 60.00, 1.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1054, 1042, 12.00, 2.00, '2026-05-31 19:00:26.128');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1055, 1048, 6.00, 3.00, '2026-05-31 19:00:24.778');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1056, 1049, 6.00, 3.00, '2026-05-31 19:00:24.825');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1057, 1047, 15.00, 2.00, '2026-05-31 19:00:25.544');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1058, 1051, 4.00, 5.00, '2026-05-31 22:42:21.149');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1059, 1052, 9.00, 2.00, '2026-05-31 22:42:21.165');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1060, 1058, 18.00, 3.00, '2026-05-31 19:00:25.870');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1061, 1059, 27.00, 3.00, '2026-05-31 19:00:25.198');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1062, 1056, 6.00, 4.00, '2026-05-31 19:00:24.732');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1063, 1057, 9.00, 3.00, '2026-05-28 18:27:24.206');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1064, 1050, 34.60, 5.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1065, 1053, 13.00, 5.00, '2026-05-31 19:00:25.585');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1066, 1054, 40.00, 5.00, '2026-05-31 19:00:24.916');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1067, 1055, 93.00, 10.00, '2026-05-31 19:00:26.158');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1068, 1060, 100.00, 5.00, '2026-05-16 09:58:11.252');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1069, 1061, 58.00, 5.00, '2026-05-31 19:00:25.054');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1070, 1065, 11.00, 5.00, '2026-05-28 18:47:08.600');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1071, 1066, 6.00, 5.00, '2026-05-28 18:47:08.623');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1072, 1063, 29.30, 5.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1073, 1064, 10.00, 5.00, '2026-05-16 09:58:46.194');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1074, 1062, 14.00, 5.00, '2026-05-31 19:00:25.021');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1075, 1067, 5.00, 5.00, '2026-05-31 22:23:59.540');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1076, 1075, 48.00, 3.00, '2026-05-31 19:07:04.903');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1077, 1073, 93.00, 3.00, '2026-05-30 16:28:01.300');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1078, 1068, 47.00, 3.00, '2026-05-31 19:00:25.955');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1079, 1069, 25.00, 2.00, '2026-05-23 14:08:00.264');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1080, 1070, 47.00, 2.00, '2026-05-31 19:00:25.633');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1081, 1071, 20.00, 1.00, '2026-05-23 14:08:35.709');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1082, 1072, 20.00, 2.00, '2026-05-31 19:00:24.877');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1083, 1074, 55.00, 1.00, '2026-05-23 14:08:13.975');
INSERT INTO [Inventories] ([InventoryId], [ProductId], [QtyInStock], [MinStock], [LastUpdated]) VALUES (1084, 1076, 53.00, 5.00, '2026-05-31 22:23:59.540');
SET IDENTITY_INSERT [Inventories] OFF;

-- Data for table Packages
SET IDENTITY_INSERT [Packages] ON;
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (2, N'PGK255', N'Combo Canh N?m', N'/images/e3c9fa77-fddb-4a12-b8c4-7a3b490be61f.jpg', N'Bao g?m nhi?u lo?i s?n ph?m', 35000.00, '2026-05-09 12:04:00.000', '2036-07-03 12:04:00.000', 25000.00, 4, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (3, N'PKG101', N'Combo Salad', N'/images/796bdfba-5802-4ba9-a0ed-706dd118673c.jpg', N'Bao g?m các s?n ph?m trong m?t gói là : 1kg dua chu?t b? hoi b? ng? vàng, 1kg cà chua bé và 1 kg cà r?t kích ngo?i hình l?i', 35000.00, '2026-05-12 05:51:00.000', '2026-05-14 05:51:00.000', 0.00, 15, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (4, N'PKG123', N'Combo Canh Bí Ð?', N'/images/bc85f654-f282-4826-a82a-609b51864e59.jpg', N'Bao g?m các 1 qu? bí n?p , 2 c? t?i và 2 gam n?m huong, thích h?p n?u canh ngày hè', 30000.00, '2026-05-21 03:31:00.000', '2036-06-07 03:31:00.000', 15000.00, 40, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (5, N'PKS12', N'Combo Rau Mu?ng Xào T?i', N'/images/f0acad35-c139-4d3a-93f4-9e3dc3d0837e.jpg', N'Bao g?m 1 bó rau mu?ng và 1 c? t?i khô , thích h?p làm món rau mu?ng xào t?i', 10000.00, '2026-05-21 03:32:00.000', '2036-06-14 03:32:00.000', 6000.00, 20, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (6, N'PKG56', N'Combo Rau C? Mix', N'/images/ff55ec6b-2c42-4080-a169-5235b31f83c3.jpg', N'Bao g?m su su , cà r?t , su hào, hành lá', 40000.00, '2026-05-12 06:36:00.000', '2026-05-18 06:36:00.000', 25000.00, 15, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (7, N'MNT100', N'Combo Rau C? Chay Bí ?n', N'/images/5f6133a9-2406-4130-85a2-e077c114227e.jpg', N'N?u b?n tò mò trong 1 pack tôi có nh?ng gì thì hãy nh?n mua ngay ', 45000.00, '2026-05-21 17:40:00.000', '2026-06-17 17:40:00.000', 35000.00, 5, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1003, N'PKA100', N'Combo Súp Lo Xào N?m', N'/images/0172cc47-b639-4762-93ac-887c8d0df842.jpg', N'Món an h?t s?c h?p d?n , giá tr? dinh du?ng cao', 35000.00, '2026-05-14 20:24:00.000', '2036-05-14 20:24:00.000', 0.00, 2, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1004, N'PKG332', N'Combo Cà Tím Xào ?t', N'/images/8b519543-6751-49f7-b9dd-b3b903737fb0.jpg', N'Bao g?m các nguyên li?u nhu ?t s?ng , cà tím. M?t món an m?i l? , bùng n? v? giác', 30000.00, '2026-05-15 03:27:00.000', '2026-05-24 03:27:00.000', 0.00, 3, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1005, N'PGG31', N'Combo T?ng H?p', N'/images/5294d60e-e165-478a-9f2b-654927f6e664.jpg', N'N?u b?n dang phân vân có th? tham kh?o gói này s? g?m nhi?u s?n ph?m mix cùng nhau , thích h?p n?u cho c? tu?n', 100000.00, '2026-05-20 18:32:00.000', '2036-06-29 06:32:00.000', 85000.00, 100, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1006, N'TLG11', N'Combo Canh Khoai Tây', N'/images/de1a542d-40d2-4300-b544-a482c2e02227.jpg', N'M?t gói s?n ph?m có th? giúp b?n thêm m?t món an trên bàn an, giúp b?n không c?n ph?i suy nghi hôm nay s? an gì.', 33000.00, '2026-05-19 06:35:00.000', '2036-05-24 06:35:00.000', 25000.00, 50, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1007, N'PK121', N'Combo An D?m Cho Bé', N'/images/d6faba32-97bc-437d-9c10-5da08ad1b520.jpg', N'M?t gói s?n ph?m dành riêng cho tr? dang an d?m, giá c? ph?i chang.Gi?m b?t n?i lo mua nh?ng s?n ph?m l? .', 55000.00, '2026-05-15 10:39:00.000', '2036-05-15 10:39:00.000', 0.00, 12, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1008, N'MGK12', N'Combo Rau C? Kho', N'/images/12865aee-73e1-432d-804a-11c860342793.jpg', N'M?t gói s?n ph?m da d?ng ', 25000.00, '2026-05-15 10:45:00.000', '2036-05-15 10:45:00.000', 0.00, 7, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1009, N'PGK22', N'Combo Mix 1', N'/images/b8a5bc7f-add7-4baf-9675-dee832984d0a.jpg', N'M?t combo hoàn h?o cho b?a an trua ho?c t?i, d?y d? giá tr? dinh du?ng', 35000.00, '2026-05-15 05:42:00.000', '2026-05-19 05:42:00.000', 27999.00, 16, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1010, N'SP1900', N'Combo Mix T?ng H?p ', N'/images/2bb1acf7-9167-4c2b-9049-7289c659c0cb.jpg', N'S? l?a ch?n hoàn h?o cho m?i b?a an hàng ngày', 45000.00, '2026-05-15 12:51:00.000', '2036-05-15 12:51:00.000', 0.00, 3, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1011, N'SMT10', N'Combo Smothie', N'/images/f691dc8c-040f-4975-8456-25716f300ead.jpg', N'M?t combo bao g?m các lo?i hoa qu? cho ', 75000.00, '2026-05-14 08:55:00.000', '2036-06-26 08:55:00.000', 50000.00, 98, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1012, N'KGP11', N'Combo Mix Tu?n ', N'/images/afbf092b-5893-4e2a-892d-86d323ee975f.jpg', N'Combo Mix Tu?n phù h?p v?i ngu?i b?n r?n, ti?t ki?m th?i gian di ch? hàng ngày', 75000.00, '2026-05-15 10:42:00.000', '2026-06-26 10:42:00.000', 50000.00, 98, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1013, N'PFG01', N'Combo Detox Gi?m Cân', N'/images/ca7a414f-78a3-463f-abbd-ce5b9d93e88f.jpg', N'M?t combo hoàn h?o cho quá trình gi?m cân', 65000.00, '2026-05-16 08:32:00.000', '2036-06-27 08:32:00.000', 52000.00, 34, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1014, N'GHK12', N'Combo Mix 2', N'/images/c0aa6da5-67af-4604-8489-02e726b309f8.jpg', N'M?t Combo da d?ng các lo?i s?n ph?m', 135000.00, '2026-05-16 01:38:00.000', '2026-06-01 01:39:00.000', 105000.00, 9, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1015, N'PKGA1', N'Como Rau Bí Xào T?i', N'/images/72d75fdb-0c30-4396-baa1-ca111a0b784a.jpg', N'M?t món an don gi?n cho b?a an trua hay an t?i ', 15000.00, '2026-05-17 08:53:00.000', '2026-05-26 08:53:00.000', 10000.00, 100, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1016, N'PGA21', N'Combo Nu?c Ép Hoa Qu? 1', N'/images/7f7485ae-5a76-4530-bf70-ab2f217ec5df.jpg', N'N?u b?n mu?n detox gi?m cân, b?n mu?n nh?ng th?c u?ng gi?i khát ngày hè oi b?c, mua combo này ngay', 85000.00, '2026-05-17 15:57:00.000', '2036-05-17 15:57:00.000', 0.00, 16, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1017, N'PGA11', N'Combo Detox Gi?m Cân 1', N'/images/fed1cd15-93ad-4ac2-a483-147f84e18bef.jpg', N'Bao g?m hoa qu? giàu ch?t dinh du?ng du?c dóng gói c?n th?n giao d?n tay khách hàng', 50000.00, '2026-05-17 01:59:00.000', '2036-05-17 01:59:00.000', 0.00, 6, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1019, N'OAA221', N'Combo Smothie Gi?m Cân 1', N'/images/d83a052d-6fe4-4a38-a191-5b7759d2650a.jpg', N'b?n c?n áp d?ng th?c don detox gi?m cân v?i các lo?i sinh t? rau c? qu? (hay còn g?i là smoothie gi?m cân).
Nguyên li?u:
• 300g d?a

• 300g xoài
• 1 trái cam

• 90g c?i bó xôi
• 1 thìa cà phê h?t chia
• 700ml nu?c', 45000.00, '2026-05-17 02:16:00.000', '2036-05-17 02:16:00.000', 0.00, 4, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1022, N'AGK123', N'Combo Detox Chanh G?ng', N'/images/d02bfca9-273c-4071-b2cd-ac3d01b429ba.jpg', N'Nguyên li?u:
• 1 qu? chanh
• 1 mi?ng g?ng', 25000.00, '2026-05-17 16:19:00.000', '2036-05-17 16:19:00.000', 0.00, 21, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1023, N'TAK11', N'Combo Sinh T? Detox', N'/images/d7509722-ee7c-4602-97af-e2c9d737439a.jpg', N'Công th?c detox 7 ngày gi?m 5kg ti?p t?c v?i sinh t? t? rau xanh và trái cây d? tang hi?u qu? gi?m cân.

Nguyên li?u:
• 500ml s?a d?a organic
• 90g c?i bó xôi

• 1 thìa cà phê h?t chia
• 2 qu? chu?i
• 300g dâu tây
• 200ml nu?c', 55000.00, '2026-05-17 16:22:00.000', '2036-07-08 16:22:00.000', 50000.00, 50, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1024, N'TTR12', N'Combo Detox Chanh Và Dua Chu?t', N'/images/693e5c96-bca0-45d8-bb01-71f379e08a18.jpg', N'Nguyên li?u:
• 1 qu? chanh
• 1 qu? dua chu?t (dua leo)
• 1 thìa cà phê m?t ong', 15000.00, '2026-05-17 02:24:00.000', '2036-06-28 02:24:00.000', 12000.00, 8, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1025, N'PKAD1', N'Combo Smothie Theo Tu?n', N'/images/daf59db0-12db-4eac-9665-5a01fccf071d.jpg', N'bao g?m các lo?i rau, c? và qu? mix theo tu?n, s? lu?ng, lo?i qu? có th? thay d?i tùy ch?nh', 125000.00, '2026-05-20 07:56:00.000', '2026-06-13 07:56:00.000', 115000.00, 5, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1026, N'PHT11', N'Combo Hoa Qu? Mix Theo Tu?n', N'/images/5ba5cacf-e315-4c8d-be27-f5028c5284af.jpg', N'Bao g?m nhi?u lo?i hoa qu? k?t h?p', 85000.00, '2026-05-21 10:49:00.000', '2026-06-29 10:49:00.000', 65000.00, 40, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1027, N'CN001', N'Combo Canh N?m 1', N'/images/f112c91b-18d7-4449-a7cf-38c30bd3511c.jpg', N'Bao g?m nhi?u lo?i n?m k?t h?p cùng v?i m?t s? lo?i rau c?', 48000.00, '2026-05-22 23:11:00.000', '2026-06-24 23:07:00.000', 42000.00, 8, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1028, N'PFD11', N'Combo Salad Mix', N'/images/a92a520b-b682-4620-bbe0-db0190366fb3.jpg', N'G?m m?t s? các s?n ph?m làm món salad', 55000.00, '2026-05-21 19:11:00.000', '2026-07-30 19:11:00.000', 50000.00, 12, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1029, N'MCX12', N'Combo Nông S?n Theo Tu?n', N'/images/d731dd68-d15f-44fb-bf1b-d48fbf66bc2f.jpg', N'Bao g?m các s?n ph?m mix theo tu?n', 75000.00, '2026-05-22 23:14:00.000', '2026-06-17 23:14:00.000', 55000.00, 3, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1030, N'FDA121', N'Combo Nu?c Ép Xoài Táo', N'/images/22a1bbba-53ce-45c7-8683-7755b80494fc.jpg', N'G?m 2 lo?i hoa qu? ', 25000.00, '2026-05-23 06:17:00.000', '2036-05-23 06:17:00.000', 0.00, 10, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1031, N'CB541', N'Combo Nu?c Ép 1', N'/images/866f6b8e-12fa-48ed-9250-d3ee598264b9.jpg', N'g?m 2 ho?c nhi?u lo?i hoa qu?', 25000.00, '2026-05-23 06:19:00.000', '2036-05-23 06:19:00.000', 0.00, 9, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1032, N'GFA12', N'Combo Rau C? Lu?c', N'/images/bdb40b2c-e7fd-455d-8c05-593f99a300ee.jpg', N'mix nông s?n', 45000.00, '2026-05-23 06:23:00.000', '2036-05-23 06:23:00.000', 0.00, 7, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1033, N'CR010', N'Combo Rau C? N?m Cà Ri', N'/images/5a173bbd-91e5-4773-8acf-7e8062d502b5.jpg', N'bao g?m nông s?n mix n?u cà ri', 50000.00, '2026-05-22 23:26:00.000', '2026-06-28 23:26:00.000', 35000.00, 3, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1034, N'MSP01', N'Combo Rau C? Cu?n Bánh Tráng', N'/images/741d16a4-ea23-424f-9093-8b85b7bd6214.jpg', N'g?m nhi?u lo?i nông s?n', 45000.00, '2026-05-23 00:36:00.000', '2026-07-02 00:36:00.000', 40000.00, 8, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1035, N'CMA01', N'Combo Rau C? Chiên Tempura', N'/images/89232464-a5b5-4f77-b884-bc9fcea19e82.jpg', N'Bao g?m các nông s?n theo mùa v?, ch?t lu?ng t?t tuy x?u mã', 85000.00, '2026-05-23 00:39:00.000', '2026-06-25 00:39:00.000', 65000.00, 2, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1036, N'CMA02', N'Combo Rau C? S?t Bo T?i', N'/images/17766455-07f9-45ba-a029-56d8d06aa1b3.jpg', N'M?t combo cho ngày m?i tuy?t v?i', 40000.00, '2026-05-23 07:43:00.000', '2036-05-23 07:43:00.000', 0.00, 8, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1037, N'CMA03', N'Combo Rau C? An Kiêng', N'/images/9ab34358-50f8-40ab-aa0c-758bdc12c1f9.jpg', N'Mix th?c ph?m t?ng h?p', 59000.00, '2026-05-23 07:46:00.000', '2036-05-23 07:46:00.000', 0.00, 7, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1038, N'CMA04', N'Combo Nông S?n T?ng H?p', N'/images/e9a25999-5c19-40ba-97d7-3234588e7fbb.jpg', N'bao g?m nhi?u nông s?n', 155000.00, '2026-05-23 08:05:00.000', '2036-05-23 08:05:00.000', 0.00, 20, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1039, N'CMBS1', N'Combo Rau C? Mix 3', N'/images/b12c69df-fde9-4eb8-ba9e-f1dd0a66923e.jpg', N'M?t combo rau c? mix bao g?m nhi?u lo?i rau c? qu? , có th? d?t mua ngay ', 225000.00, '2026-05-28 11:05:00.000', '2026-07-16 11:05:00.000', 175000.00, 98, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1040, N'SSA02', N'Combo Hoa Q?a Mix 9', N'/images/fbf0dc1c-91e2-4d25-a77a-0d1e00f9076d.jpg', N'nhi?u lo?i hoa qu?', 450000.00, '2026-05-28 11:08:00.000', '2026-07-10 11:08:00.000', 399999.00, 997, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1041, N'CBX12', N'Combo Rau Canh Mix', N'/images/84c418f7-4ce9-41ee-b0eb-5145129612e0.jpg', N'Mix l?n nhi?u lo?i rau', 150000.00, '2026-05-28 11:10:00.000', '2026-07-09 11:10:00.000', 145000.00, 995, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1042, N'SAL', N'Combo Hoa Qu? 10', N'/images/48dcd74c-508c-4bd7-adbb-6360300c6093.jpg', N'mix l?n nh?ng lo?i hoa qu? ', 10000.00, '2026-05-28 11:12:00.000', '2026-07-08 11:12:00.000', 90000.00, 95, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1043, N'TH001', N'Combo Rau C? T?ng H?p', N'/images/8c0b7be0-ea0c-40b4-a15a-b110588cac0b.jpg', N'Ða d?ng các lo?i rau c? qu?, d?y dinh du?ng
Không ph?i lan tan v? giá', 50000.00, '2026-05-28 11:17:00.000', '2026-07-12 11:17:00.000', 48000.00, 998, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1044, N'TH002', N'Combo Rau C? T?ng H?p 2', N'/images/5dc22afe-1021-438a-b3f6-48471b16e5fa.jpg', N'Mix l?n rau c?
Không lo v? ch?t lu?ng
Không lo v? giá', 65000.00, '2026-05-28 11:19:00.000', '2026-07-10 11:19:00.000', 0.00, 999997, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1045, N'TH003', N'Combo T?ng H?p 3', N'/images/c92fe4b5-4cc8-41d1-9a0a-143837f5fc0e.jpg', N'Mix l?n rau c? các lo?i
Dinh du?ng d?y d?
Thích h?p cho ngu?i an chay', 80000.00, '2026-05-28 11:35:00.000', '2026-07-02 11:35:00.000', 0.00, 999997, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1046, N'CBC01', N'Combo Chay 1', N'/images/ab6ff731-ed97-4375-8afe-0e82ce9032b8.jpg', N'Phù h?p cho ngu?i gi?m cân
Chi phí ph?i chang
Không lo v? ch?t lu?ng và dinh du?ng', 100000.00, '2026-05-27 21:39:00.000', '2026-07-02 21:39:00.000', 55000.00, 10, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1047, N'CBC02', N'Combo T?ng H?p Rau Mix N?m', N'/images/d88c9cae-8dc0-49ce-8dbb-cc7055f0d9ce.jpg', N'G?m các lo?i rau thom
Các lo?i n?m', 165000.00, '2026-05-27 21:41:00.000', '2026-06-30 21:41:00.000', 99999.00, 6, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1048, N'CAD01', N'Sinh T? Mix ', N'/images/1c4738b4-824e-4342-9fd7-2d8ba01668e8.jpg', N'Combo sinh t? mix
Phù h?p cho ngu?i c?n gi?m cân
Không lo v? giá', 100000.00, '2026-04-29 21:58:00.000', '2026-07-01 21:58:00.000', 78000.00, 7, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1049, N'CABAS', N'Package Vegetable', N'/images/087af504-eb47-4e68-a55f-501f0538685b.jpg', N'my package has many vegetable
deliver quick', 150000.00, '2026-05-14 12:01:00.000', '2026-06-30 12:01:00.000', 110000.00, 37, 1);
INSERT INTO [Packages] ([PackageId], [PackageCode], [PackageName], [ImageUrl], [Description], [Price], [StartDate], [EndDate], [Discount], [MaxQuantity], [IsActive]) VALUES (1050, N'FF1A1', N'Mix L?n Hoa Qu? và Rau C? 1', N'/images/41cab19f-c56e-4ff7-9e0a-fa6257daf9ca.jpg', N'Mix t?ng h?p hoa qu? và rau c?
Combo giá r?', 90000.00, '2026-05-29 10:50:00.000', '2026-07-04 10:50:00.000', 79000.00, 999995, 1);
SET IDENTITY_INSERT [Packages] OFF;

-- Data for table PackageItems
SET IDENTITY_INSERT [PackageItems] ON;
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3298, 1017, 5, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3299, 1017, 1050, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3300, 1017, 18, 3.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3301, 1019, 1050, 1.10);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3302, 1019, 1014, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3303, 1019, 1028, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3304, 1019, 10, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3305, 1022, 1022, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3306, 1022, 1005, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3313, 1008, 24, 0.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3314, 1008, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3315, 1008, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3316, 1009, 1, 0.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3317, 1009, 27, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3318, 1009, 21, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3319, 1007, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3320, 1007, 11, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3321, 1007, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3322, 1007, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3323, 1007, 12, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3324, 1010, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3325, 1010, 27, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3326, 1010, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3327, 1010, 1009, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3333, 1011, 4, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3334, 1011, 23, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3335, 1011, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3336, 1011, 1050, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3337, 1011, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3346, 1016, 23, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3347, 1016, 1014, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3348, 1016, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3349, 1016, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3350, 1016, 1053, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3351, 1016, 1050, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3352, 1015, 1059, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3353, 1015, 17, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3354, 1014, 8, 4.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3355, 1014, 1026, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3356, 1014, 1039, 6.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3357, 1014, 1037, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3358, 1014, 1007, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3359, 1014, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3360, 1014, 26, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3361, 1014, 14, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3362, 1014, 1010, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3363, 1013, 2, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3364, 1013, 5, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3365, 1013, 1027, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3366, 1013, 18, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3367, 1013, 1022, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3368, 1038, 1073, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3369, 1038, 1007, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3370, 1038, 9, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3371, 1038, 1010, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3372, 1038, 1031, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3373, 1038, 1021, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3374, 1038, 1020, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3375, 1038, 1027, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3376, 1038, 1016, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3377, 1038, 1030, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3378, 1037, 2, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3379, 1037, 1008, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3380, 1037, 5, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3381, 1037, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3382, 1037, 3, 1.40);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3383, 1037, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3384, 1036, 15, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3385, 1036, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3386, 1036, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3387, 1036, 22, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3388, 1036, 17, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3389, 1029, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3390, 1029, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3391, 1029, 1009, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3392, 1029, 1027, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3393, 1029, 1013, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3394, 1029, 1028, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3395, 1034, 2, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3396, 1034, 1, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3397, 1034, 1008, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3398, 1034, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3399, 1034, 1057, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3400, 1035, 12, 0.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3401, 1035, 7, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3402, 1035, 15, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3403, 1035, 11, 2.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3404, 1035, 1038, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3405, 1035, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3406, 1030, 10, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3407, 1030, 5, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3408, 1023, 4, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3409, 1023, 23, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3410, 1023, 1028, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3411, 1031, 1050, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3412, 1031, 1014, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3413, 1031, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3414, 1032, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3415, 1032, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3416, 1032, 1004, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3417, 1032, 1037, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3418, 1032, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3419, 1033, 24, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3420, 1033, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3421, 1033, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3422, 1033, 1012, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3423, 1033, 27, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3424, 1033, 1009, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3425, 1024, 1022, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3426, 1024, 2, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3427, 1025, 18, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3428, 1025, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3429, 1025, 1028, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3430, 1025, 4, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3431, 1025, 1014, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3432, 1025, 1015, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3433, 1025, 1050, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3434, 1025, 5, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3435, 1025, 1033, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3436, 1025, 23, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3437, 1025, 2, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3441, 1027, 14, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3442, 1027, 15, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3443, 1027, 1075, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3444, 1027, 27, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3445, 1027, 8, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3452, 1012, 1010, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3453, 1012, 9, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3454, 1012, 12, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3455, 1012, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3456, 1012, 17, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3457, 1012, 22, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3458, 1012, 1004, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3459, 1012, 1013, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3466, 1039, 1067, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3467, 1039, 1044, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3468, 1039, 1046, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3469, 1039, 1063, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3470, 1039, 1051, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3471, 1039, 1012, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3472, 1039, 1076, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3473, 1039, 1052, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3474, 1040, 1035, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3475, 1040, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3476, 1040, 1015, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3477, 1040, 1032, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3478, 1040, 1034, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3479, 1040, 1047, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3480, 1040, 1053, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3481, 1040, 1070, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3482, 1041, 1024, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3483, 1041, 1025, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3484, 1041, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3485, 1041, 1059, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3486, 1041, 24, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3487, 1041, 1004, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3488, 1042, 1072, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3489, 1042, 1054, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3490, 1042, 1032, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3491, 1042, 1033, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3492, 1042, 1062, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3493, 1042, 1061, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3494, 1043, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3495, 1043, 1024, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3496, 1043, 1013, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3497, 1043, 1026, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3498, 1043, 1041, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3499, 1044, 19, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3500, 1044, 1021, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3501, 1044, 1030, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3502, 1044, 1028, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3503, 1044, 1040, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3504, 1045, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3505, 1045, 7, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3506, 1045, 9, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3507, 1045, 1009, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3508, 1045, 1021, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3509, 1045, 1063, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3516, 1046, 1027, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3517, 1046, 1029, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3518, 1046, 1037, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3519, 1046, 1040, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3520, 1046, 27, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3521, 1046, 1058, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3531, 1047, 15, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3532, 1047, 14, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3533, 1047, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3534, 1047, 1007, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3535, 1047, 28, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3536, 1047, 1012, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3537, 1047, 1056, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3538, 1047, 1048, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3539, 1047, 1049, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3546, 1048, 1073, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3547, 1048, 1014, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3548, 1048, 10, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3549, 1048, 1015, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3550, 1048, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3551, 1048, 1047, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3552, 1049, 1067, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3553, 1049, 1068, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3554, 1049, 1024, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3555, 1049, 1027, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3556, 1049, 1045, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3557, 1049, 1038, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3558, 1049, 1042, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3559, 1049, 1055, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3560, 1050, 1040, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3561, 1050, 1051, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3562, 1050, 1052, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3563, 1050, 1045, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3564, 1050, 1039, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3565, 1050, 1025, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3566, 1050, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3567, 1050, 4, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3568, 1050, 1029, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3586, 7, 12, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3587, 7, 16, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3588, 7, 21, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3589, 7, 9, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3590, 1003, 21, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3591, 1003, 1011, 0.20);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3592, 1003, 27, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3593, 1004, 7, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3594, 1004, 1011, 0.30);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3605, 1026, 1062, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3606, 1026, 1017, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3607, 1026, 1019, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3608, 1026, 1034, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3609, 1026, 1055, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3610, 1026, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3611, 1026, 1069, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3612, 1028, 1004, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3613, 1028, 1008, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3614, 1028, 1, 1.50);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3615, 1028, 3, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3616, 1028, 1036, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3621, 1005, 8, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3622, 1005, 12, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3623, 1005, 19, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3624, 1005, 24, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3625, 1005, 13, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3626, 1005, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3627, 1005, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3628, 1005, 1009, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3629, 1006, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3630, 1006, 24, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3631, 1006, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3632, 6, 20, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3633, 6, 22, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3634, 6, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3635, 6, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3636, 5, 13, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3637, 5, 17, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3638, 4, 12, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3639, 4, 17, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3640, 4, 14, 2.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3665, 2, 14, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3666, 2, 15, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3667, 2, 1065, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3668, 2, 1066, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3669, 2, 7, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3670, 2, 6, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3674, 3, 3, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3675, 3, 1, 1.00);
INSERT INTO [PackageItems] ([PackageItemId], [PackageId], [ProductId], [PackageQty]) VALUES (3676, 3, 2, 1.00);
SET IDENTITY_INSERT [PackageItems] OFF;

-- Data for table InventoryTransactions
SET IDENTITY_INSERT [InventoryTransactions] ON;
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1, 1, NULL, 3.50, N'Nh?p l?n d?u', '2026-05-13 15:23:01.807', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2, 1, NULL, 4.00, N'Nh?p l?n 2', '2026-05-13 15:31:44.146', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3, 2, NULL, 25.00, N'Lô d?u
', '2026-05-13 15:40:40.460', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4, 3, NULL, 10.50, N'Nh?p m?i', '2026-05-13 15:40:55.177', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (5, 4, NULL, 10.00, N'Lô d?u tiên', '2026-05-14 14:23:32.290', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (6, 5, NULL, 25.00, N'Nh?p l?n d?u', '2026-05-14 14:24:04.674', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (7, 6, NULL, 15.00, N'Nh?p m?i', '2026-05-14 14:24:25.292', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (8, 7, NULL, 10.00, N'L?n d?u', '2026-05-14 14:24:40.234', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (9, 8, NULL, 30.00, N'Nh?p m?i', '2026-05-14 14:24:58.474', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (10, 9, NULL, 100.00, N'Nh?p m?i', '2026-05-14 14:25:15.087', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (11, 10, NULL, 25.00, N'Nh?p m?i', '2026-05-14 14:25:37.098', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (12, 11, NULL, 15.00, N'Lô d?u', '2026-05-14 14:25:55.329', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (13, 12, NULL, 45.00, N'Nh?p m?i', '2026-05-14 14:26:29.739', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (14, 13, NULL, 100.00, N'Nh?p m?i', '2026-05-14 14:26:57.007', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (15, 14, NULL, 45.00, N'Nh?p m?i', '2026-05-14 14:27:20.714', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (16, 6, NULL, 5.00, N'Nh?p l?n hai', '2026-05-14 14:28:02.429', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (17, 15, NULL, 20.00, N'Lô d?u', '2026-05-14 14:33:31.947', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (18, 16, NULL, 35.00, N'Lô d?u', '2026-05-14 14:34:09.909', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (19, 9, 4, -1.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514220152)', '2026-05-14 22:01:53.043', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (20, 8, 4, -2.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514220152)', '2026-05-14 22:01:54.609', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (21, 10, 4, -2.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514220152)', '2026-05-14 22:01:54.679', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (22, 15, 5, -1.00, N'Tr? kho ph?c v? gói Combo Combo Rau Mu?ng Xào T?i (Mã don: ORD-20260514220152)', '2026-05-14 22:01:54.828', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (23, 8, 5, -2.00, N'Tr? kho ph?c v? gói Combo Combo Rau Mu?ng Xào T?i (Mã don: ORD-20260514220152)', '2026-05-14 22:01:54.935', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (24, 9, 4, -1.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.434', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (25, 8, 4, -2.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.666', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (26, 10, 4, -2.00, N'Tr? kho ph?c v? gói Combo Combo Canh Bí Ð? (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.727', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (27, 3, 3, -2.00, N'Tr? kho ph?c v? gói Combo Combo Salad (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.800', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (28, 1, 3, -2.00, N'Tr? kho ph?c v? gói Combo Combo Salad (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.893', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (29, 2, 3, -2.00, N'Tr? kho ph?c v? gói Combo Combo Salad (Mã don: ORD-20260514221046)', '2026-05-14 22:10:46.919', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (30, 17, NULL, 1000.00, N'Lô d?u', '2026-05-14 15:14:07.154', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (31, 18, NULL, 50.00, N'l?n d?u', '2026-05-14 15:14:31.520', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (32, 19, NULL, 29.00, N'l?n m?t', '2026-05-14 15:16:40.973', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (33, 19, NULL, 5.00, N'L?n 2', '2026-05-14 15:17:03.500', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (34, 20, NULL, 75.00, N'Nh?p m?i', '2026-05-14 15:17:24.134', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (35, 7, NULL, 25.00, N'Nh?p m?i', '2026-05-14 15:18:04.844', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (36, 21, NULL, 55.00, N'Nh?p m?i', '2026-05-14 15:18:43.298', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1008, 1009, NULL, 40.00, N'Nh?p m?i', '2026-05-15 13:52:30.100', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1009, 1010, NULL, 14.00, N'Nh?p m?i', '2026-05-15 13:52:46.800', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1042, 1007, NULL, 25.00, N'Nh?p m?i
', '2026-05-15 15:29:35.340', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1043, 3, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:18.940', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1044, 1, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.032', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1045, 2, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.064', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1046, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.143', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1047, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.226', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1048, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.259', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1049, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.292', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1050, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.342', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1051, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.377', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1052, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.406', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1053, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515223018-9697)', '2026-05-15 22:30:19.447', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1060, 1005, NULL, 10.00, N'l?n 2', '2026-05-15 15:36:47.830', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1061, 1006, NULL, 15.00, N'Thêm l?n 2', '2026-05-15 15:39:17.844', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1062, 1011, NULL, 25.00, N'L?n 2', '2026-05-15 15:39:28.935', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1063, 1008, NULL, 55.00, N'thêm', '2026-05-15 15:39:41.833', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1064, 1, NULL, 25.00, N'thêm l?n 3', '2026-05-15 15:40:02.613', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1065, 3, NULL, 45.00, N'L?n 2', '2026-05-15 15:40:17.847', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1066, 3, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1067, 1, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1068, 2, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.717', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1069, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.781', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1070, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.867', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1071, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.917', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1072, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.938', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1073, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:45.984', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1074, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:46.020', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1075, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:46.051', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1076, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260515225245-eb0c)', '2026-05-15 22:52:46.084', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1077, 1013, NULL, 35.00, N'Nh?p m?i', '2026-05-15 16:02:27.491', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1078, 1016, NULL, 45.00, N'Nh?p m?i', '2026-05-15 16:02:40.762', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1079, 1014, NULL, 75.00, N'Nh?p m?i', '2026-05-15 16:03:01.614', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1080, 1015, NULL, 55.00, N'Nh?p m?i', '2026-05-15 16:03:10.160', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1081, 1017, NULL, 20.00, N'L?n nh?p m?i', '2026-05-15 17:17:18.365', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1082, 1018, NULL, 15.00, N'Nh?p m?i', '2026-05-15 17:17:47.658', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1083, 1019, NULL, 22.00, N'Nh?p m?i', '2026-05-15 17:18:03.608', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1084, 1020, NULL, 10.00, N'Nh?p', '2026-05-15 17:41:42.533', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1085, 1021, NULL, 100.00, N'Nh?p', '2026-05-15 17:41:50.068', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1086, 1012, NULL, 35.00, N'Nh?p', '2026-05-15 17:42:05.995', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1087, 9, 7, -3.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:42.570', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1088, 1007, 7, -3.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:42.959', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1089, 14, 7, -3.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.008', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1090, 7, 7, -4.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.039', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1091, 14, 1003, -6.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.150', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1092, 1019, 1003, -0.60, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.234', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1093, 1005, 1003, -3.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.273', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1094, 1, 1006, -3.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.363', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1095, 18, 1006, -3.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.408', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1096, 6, 1006, -3.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516004842-19b2)', '2026-05-16 00:48:43.488', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1097, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.500', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1098, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.675', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1099, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.705', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1100, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.768', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1101, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.848', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1102, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.891', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1103, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1104, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:14.952', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1105, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:15.002', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1106, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:15.053', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1107, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:15.087', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1108, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516005414-6950)', '2026-05-16 00:54:15.110', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1109, 1022, NULL, 30.00, N'Nh?p m?i', '2026-05-16 08:24:32.272', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1110, 1029, NULL, 25.00, N'Nh?p m?i', '2026-05-16 08:24:47.908', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1111, 1028, NULL, 15.00, N'Nh?p m?i', '2026-05-16 08:25:02.677', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1112, 1027, NULL, 15.00, N'Nh?p m?i', '2026-05-16 08:25:17.853', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1113, 1026, NULL, 35.00, N'Nh?p m?i', '2026-05-16 08:25:27.757', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1114, 1025, NULL, 45.00, N'Nh?p m?i', '2026-05-16 08:25:38.438', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1115, 1023, NULL, 55.00, N'Nh?p m?i', '2026-05-16 08:25:51.785', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1116, 1024, NULL, 25.00, N'Nh?p m?i', '2026-05-16 08:26:10.156', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1117, 1037, NULL, 26.00, N'L?n d?u', '2026-05-16 09:07:04.852', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1118, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:00.541', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1119, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.010', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1120, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.039', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1121, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.069', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1122, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.097', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1123, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.125', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1124, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.153', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1125, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.179', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1126, 1006, 1004, -1.00, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1127, 1019, 1004, -0.30, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.317', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1128, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.390', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1129, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.430', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1130, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.468', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1131, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.500', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1132, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.562', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1133, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.724', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1134, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.769', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1135, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.819', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1136, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516163100-9e2d)', '2026-05-16 16:31:01.853', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1137, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.738', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1138, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.791', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1139, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.827', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1140, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.853', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1141, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.888', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1142, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:11.951', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1143, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260516163211-ea38)', '2026-05-16 16:32:12.001', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1144, 1074, NULL, 25.00, N'Nh?p l?n 1', '2026-05-16 09:35:42.226', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1145, 1075, NULL, 10.00, N'Nh?p m?i', '2026-05-16 09:35:52.822', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1146, 1053, NULL, 50.00, N'Nh?p', '2026-05-16 09:43:59.620', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1147, 1050, NULL, 25.00, N'Nh?p', '2026-05-16 09:44:07.173', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1148, 1047, NULL, 38.00, N'Nh?p', '2026-05-16 09:44:19.402', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1149, 1048, NULL, 34.00, N'Nh?p', '2026-05-16 09:44:28.304', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1150, 1036, NULL, 8.00, N'Nh?p', '2026-05-16 09:44:46.457', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1151, 1034, NULL, 50.00, N'Nh?p', '2026-05-16 09:44:55.371', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1152, 1033, NULL, 50.00, N'Nh?p', '2026-05-16 09:45:10.584', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1153, 1031, NULL, 45.00, N'Nh?p', '2026-05-16 09:45:17.800', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1154, 1032, NULL, 20.00, N'Nh?p', '2026-05-16 09:45:30.344', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1155, 1030, NULL, 20.00, N'Nh?p', '2026-05-16 09:45:42.476', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1156, 1064, NULL, 22.00, N'Nh?p', '2026-05-16 09:45:55.513', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1157, 1067, NULL, 100.00, N'Nh?p', '2026-05-16 09:46:05.099', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1158, 1070, NULL, 20.00, N'Nh?p', '2026-05-16 09:46:11.854', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1159, 1071, NULL, 15.00, N'Nh?p', '2026-05-16 09:46:19.532', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1160, 1065, NULL, 20.00, N'Nh?p', '2026-05-16 09:46:32.243', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1161, 1042, NULL, 100.00, N'Nh?p', '2026-05-16 09:46:46.505', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1162, 1043, NULL, 25.00, N'Nh?p', '2026-05-16 09:46:58.520', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1163, 1040, NULL, 40.00, N'Nh?p', '2026-05-16 09:47:12.957', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1164, 1038, NULL, 31.00, N'Nh?p', '2026-05-16 09:47:22.992', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1165, 1035, NULL, 18.00, N'Nh?p', '2026-05-16 09:47:37.824', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1166, 1059, NULL, 15.00, N'Nh?p', '2026-05-16 09:56:58.858', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1167, 1062, NULL, 10.00, N'Nh?p', '2026-05-16 09:57:06.071', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1168, 1060, NULL, 20.00, N'Nh?p', '2026-05-16 09:57:13.353', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1169, 1044, NULL, 100.00, N'Nh?p', '2026-05-16 09:57:30.955', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1170, 1066, NULL, 45.00, N'Nh?p', '2026-05-16 09:58:04.323', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1171, 1068, NULL, 100.00, N'Nh?p', '2026-05-16 09:58:11.252', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1172, 1069, NULL, 65.50, N'Nh?p', '2026-05-16 09:58:22.976', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1173, 1072, NULL, 33.30, N'Nh?p', '2026-05-16 09:58:37.291', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1174, 1073, NULL, 10.00, N'Nh?p', '2026-05-16 09:58:46.194', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1175, 1052, NULL, 10.00, N'Nh?p', '2026-05-16 09:59:00.302', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1176, 1, 1009, -1.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.195', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1177, 1005, 1009, -6.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.292', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1178, 14, 1009, -6.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.342', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1179, 4, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.579', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1180, 12, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.624', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1181, 1044, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.652', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1182, 1064, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.674', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1183, 21, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.692', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1184, 1, 1006, -2.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.741', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1185, 18, 1006, -2.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.825', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1186, 6, 1006, -2.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516170105-3775)', '2026-05-16 17:01:05.855', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1187, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.061', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1188, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.188', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1189, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.218', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1190, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.251', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1191, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1192, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.331', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1193, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.356', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1194, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.412', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1195, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.453', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1196, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516170212-ae89)', '2026-05-16 17:02:12.477', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1197, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516170307-9094)', '2026-05-16 17:03:07.898', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1198, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516170307-9094)', '2026-05-16 17:03:08.060', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1199, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260516170307-9094)', '2026-05-16 17:03:08.096', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1200, 1, NULL, 5.00, N'Nh?p m?i', '2026-05-16 14:06:03.833', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1201, 7, NULL, 3.00, N'Ði?u ch?nh', '2026-05-16 14:19:14.636', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1202, 1056, NULL, 10.00, N'Nh?p m?i', '2026-05-16 14:21:25.291', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1203, 1005, NULL, 20.00, N'Ði?u ch?nh', '2026-05-16 14:21:41.743', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1204, 1058, NULL, 10.00, N'Nh?p m?i', '2026-05-16 14:21:57.960', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1205, 1061, NULL, 15.00, N'Nh?p m?i', '2026-05-16 14:22:18.321', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1206, 1055, NULL, 10.00, N'Nh?p m?i', '2026-05-16 14:22:38.271', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1207, 8, NULL, 2.00, N'Ði?u ch?nh', '2026-05-16 14:23:01.457', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1208, 1039, NULL, 20.00, N'Nh?p', '2026-05-16 21:34:54.923', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1209, 1041, NULL, 45.50, N'Nh?p', '2026-05-16 21:35:09.874', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1210, 1063, NULL, 10.00, N'Nh?p', '2026-05-16 21:35:28.053', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1211, 1051, NULL, 40.50, N'Nh?p', '2026-05-16 21:35:41.709', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1212, 1045, NULL, 25.50, N'Nh?p', '2026-05-16 21:35:58.620', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1213, 1046, NULL, 25.00, N'Nh?p', '2026-05-16 21:36:16.932', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1214, 1054, NULL, 15.00, N'Nh?p', '2026-05-16 21:36:27.938', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1215, 1049, NULL, 21.90, N'Nh?p', '2026-05-16 21:36:40.840', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1216, 1057, NULL, 20.00, N'Nh?p', '2026-05-16 21:36:54.828', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1217, 1012, NULL, 1.00, N'Ði?u ch?nh', '2026-05-16 21:37:27.188', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1218, 1013, NULL, 2.00, N'Nh?p l?n 2', '2026-05-16 21:37:41.037', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1219, 1017, NULL, 4.50, N'Nh?p l?n 2', '2026-05-16 21:38:00.409', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1220, 1020, NULL, 5.50, N'Nh?p', '2026-05-16 21:38:20.504', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1221, 1014, NULL, 1.00, N'Nh?p', '2026-05-16 21:38:36.623', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1222, 1043, NULL, 1.50, N'Nh?p m?i', '2026-05-16 21:38:54.987', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1223, 1042, NULL, 1.50, N'Nh?p', '2026-05-16 21:39:10.575', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1224, 4, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:17.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1225, 12, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:17.931', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1226, 1044, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.090', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1227, 1064, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.124', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1228, 21, 1011, -2.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.175', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1229, 11, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.236', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1230, 9, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.285', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1231, 13, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.308', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1232, 18, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.336', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1233, 15, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.357', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1234, 6, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.386', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1235, 1009, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.409', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1236, 1017, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.432', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1237, 15, 5, -3.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.475', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1238, 8, 5, -6.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.506', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1239, 1018, 1012, -3.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.543', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1240, 7, 1012, -4.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.566', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1241, 9, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.590', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1242, 1007, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.634', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1243, 8, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1244, 1010, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.699', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1245, 1012, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.728', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1246, 1020, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260516214617-96f1)', '2026-05-16 21:46:18.753', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1247, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.286', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1248, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.326', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1249, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.342', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1250, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.367', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1251, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.413', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1252, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.454', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1253, 14, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.514', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1254, 1005, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.548', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1255, 1, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.668', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1256, 1017, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260516214948-c492)', '2026-05-16 21:49:48.692', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1257, 3, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.275', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1258, 1, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.394', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1259, 2, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.434', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1260, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.485', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1261, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.534', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1262, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.578', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1263, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.598', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1264, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.657', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1265, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.694', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1266, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.723', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1267, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.760', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1268, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.802', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1269, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.826', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1270, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.844', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1271, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.870', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1272, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516220253-12b0)', '2026-05-16 22:02:53.893', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1273, 4, NULL, 30.00, N'Nh?p l?n m?i nh?t', '2026-05-16 22:05:26.472', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1274, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.417', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1275, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.612', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1276, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.647', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1277, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.675', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1278, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.698', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1279, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.745', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1280, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.814', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1281, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.850', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1282, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.890', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1283, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.913', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1284, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1285, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:04.966', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1286, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.008', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1287, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.030', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1288, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.055', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1289, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.079', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1290, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.123', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1291, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.156', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1292, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260516221504-2b15)', '2026-05-16 22:15:05.175', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1293, 1037, NULL, 0.50, N'Nh?p m?i', '2026-05-16 22:33:58.283', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1294, 1038, NULL, 20.00, N'Nh?p m?i', '2026-05-16 22:34:25.337', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1295, 1047, NULL, 10.00, N'Nh?p', '2026-05-16 22:34:41.905', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1296, 1048, NULL, 2.00, N'Nh?p', '2026-05-16 22:34:56.126', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1297, 1044, NULL, 0.50, N'Nh?p', '2026-05-16 22:35:17.402', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1298, 1050, NULL, 10.00, N'Nh?p', '2026-05-16 22:35:37.637', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1299, 1052, NULL, 10.50, N'Nh?p', '2026-05-16 22:35:55.020', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1300, 1053, NULL, 12.00, N'Nh?p', '2026-05-16 22:36:09.602', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1301, 1040, NULL, 1.00, N'Nh?p', '2026-05-16 22:36:33.401', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1302, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.177', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1303, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.400', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1304, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.437', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1305, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.481', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1306, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.521', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1307, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.561', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1308, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.588', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1309, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.616', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1310, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.654', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1311, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.725', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1312, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.789', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1313, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.816', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1314, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.837', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1315, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.855', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1316, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.907', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1317, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:49.967', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1318, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:50.009', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1319, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:50.035', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1320, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260516224249-346f)', '2026-05-16 22:42:50.074', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1321, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.094', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1322, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.873', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1323, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.914', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1324, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.935', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1325, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.951', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1326, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:23.985', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1327, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.049', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1328, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.071', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1329, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.097', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1330, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.135', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1331, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.156', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1332, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.177', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1333, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.219', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1334, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.257', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1335, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.274', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1336, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260518053922-7c4b)', '2026-05-18 05:39:24.304', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1337, 1061, 1015, -6.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.094', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1338, 8, 1015, -3.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.328', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1339, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.377', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1340, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.428', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1341, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.460', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1342, 12, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.510', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1343, 1023, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.535', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1344, 21, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.557', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1345, 1044, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.579', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1346, 1065, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.596', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1347, 1064, 1016, -2.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260518060326-2732)', '2026-05-18 06:03:26.617', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1348, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.264', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1349, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.328', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1350, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.390', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1351, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.452', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1352, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.507', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1353, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.535', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1354, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260518060419-ee6b)', '2026-05-18 06:04:19.560', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1355, 8, NULL, 20.00, N'Nh?p m?i', '2026-05-18 06:09:42.266', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1356, 6, NULL, 25.00, N'Nh?p m?i', '2026-05-18 06:10:16.834', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1357, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:34.284', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1358, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.284', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1359, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.350', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1360, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.443', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1361, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.487', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1362, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.513', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1363, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.547', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1364, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.600', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1365, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.639', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1366, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.672', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1367, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.704', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1368, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.752', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1369, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.792', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1370, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.818', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1371, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.868', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1372, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.900', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1373, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1374, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:35.957', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1375, 1038, 1022, -2.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:36.004', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1376, 1014, 1022, -2.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260519122034-45f7)', '2026-05-19 12:20:36.039', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1383, 11, NULL, 35.00, N'Nh?p thêm', '2026-05-19 12:24:14.710', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1384, 1, 1009, -0.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.607', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1385, 1005, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.639', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1386, 14, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.655', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1387, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.681', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1388, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.738', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1389, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.782', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1390, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.831', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1391, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.857', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1392, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.881', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1393, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.897', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1394, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.913', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1395, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.934', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1396, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.956', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1397, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.973', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1398, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:03.989', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1399, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.026', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1400, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.054', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1401, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.087', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1402, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.110', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1403, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.130', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1404, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.147', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1405, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.163', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1406, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.181', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1407, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.206', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1408, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260519122503-fe2d)', '2026-05-19 12:25:04.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1409, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:40.562', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1410, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:43.066', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1411, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:43.447', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1412, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:44.059', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1413, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:44.264', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1414, 1064, 1019, -1.10, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:44.756', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1415, 1023, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.031', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1416, 1034, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.290', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1417, 21, 1019, -1.50, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.382', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1418, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.556', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1419, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.666', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1420, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.784', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1421, 12, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:45.983', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1422, 1023, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:46.176', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1423, 21, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:46.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1424, 1044, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:46.683', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1425, 1065, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:46.946', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1426, 1064, 1016, -2.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:47.181', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1427, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:47.463', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1428, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:47.663', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1429, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:47.797', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1430, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:47.969', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1431, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260520001539-8564)', '2026-05-20 00:15:48.130', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1432, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.016', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1433, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.318', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1434, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.423', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1435, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.495', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1436, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.543', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1437, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.578', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1438, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.638', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1439, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.679', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1440, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.797', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1441, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.857', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1442, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.935', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1443, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:40.978', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1444, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.013', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1445, 1064, 1019, -1.10, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.077', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1446, 1023, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.147', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1447, 1034, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.198', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1448, 21, 1019, -1.50, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.250', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1449, 3, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.315', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1450, 1, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.356', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1451, 2, 3, -3.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.388', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1452, 15, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.441', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (1453, 8, 5, -4.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260520004239-8210)', '2026-05-20 00:42:41.489', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2377, 2, NULL, 25.00, N'Nh?p', '2026-05-20 07:52:12.739', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2378, 1010, NULL, 100.00, N'Nh?p', '2026-05-20 07:52:25.749', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2379, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:42.522', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2380, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:42.808', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2381, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:42.889', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2382, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:42.976', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2383, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.001', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2384, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.031', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2385, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.053', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2386, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.074', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2387, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.092', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2388, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.124', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2389, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260520080242-4b75)', '2026-05-20 08:02:43.173', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2390, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.801', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2391, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.836', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2392, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.861', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2393, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2394, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2395, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:23.979', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2396, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520080523-f1d5)', '2026-05-20 08:05:24.011', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2397, 1, NULL, 25.00, N'Nh?p', '2026-05-20 08:12:42.712', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2398, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.241', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2399, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.402', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2400, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2401, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.517', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2402, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.554', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2403, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.627', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2404, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.674', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2405, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260520160723-f906)', '2026-05-20 16:07:23.714', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2406, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:43.793', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2407, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:43.825', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2408, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:43.841', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2409, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:43.865', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2410, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.090', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2411, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.119', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2412, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.138', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2413, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.161', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2414, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.182', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2415, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.210', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2416, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.234', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2417, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.254', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2418, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.284', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2419, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.315', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2420, 1, 1009, -0.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.339', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2421, 1005, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.359', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2422, 14, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.378', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2423, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.406', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2424, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2425, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260520160843-ede2)', '2026-05-20 16:08:44.455', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2426, 10, NULL, 45.00, N'Nh?p', '2026-05-20 16:10:15.630', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2427, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:06.968', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2428, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.137', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2429, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.168', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2430, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.199', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2431, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.223', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2432, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.246', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2433, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.272', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2434, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2435, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.354', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2436, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.419', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2437, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2438, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.476', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2439, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.493', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2440, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.516', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2441, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.541', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2442, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.571', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2443, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.602', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2444, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.648', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2445, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.681', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2446, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.705', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2447, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.729', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2448, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.752', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2449, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260521072706-a6a0)', '2026-05-21 07:27:07.771', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2450, 1018, 1012, 1.50, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.273', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2451, 7, 1012, 2.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.660', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2452, 9, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.679', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2453, 1007, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.699', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2454, 8, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.711', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2455, 1010, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.722', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2456, 1012, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.733', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2457, 1020, 1012, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.744', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2458, 11, 1014, 4.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.754', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2459, 1032, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.777', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2460, 1047, 1014, 6.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.788', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2461, 1045, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.800', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2462, 1016, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.812', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2463, 21, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.823', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2464, 17, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.842', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2465, 10, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.853', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2466, 1018, 1014, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.865', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2467, 10, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.877', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2468, 19, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.897', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2469, 1070, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.909', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2470, 1071, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.919', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2471, 1006, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.930', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2472, 6, 2, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260521072706-a6a0', '2026-05-21 07:33:02.941', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2473, 1064, 1019, -1.10, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.160', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2474, 1023, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.192', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2475, 1034, 1019, -1.00, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.210', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2476, 21, 1019, -1.50, N'Xu?t kho cho combo Combo Somthie Gi?m Cân 1 (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.226', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2477, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.265', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2478, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.306', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2479, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260521073342-711d)', '2026-05-21 07:33:42.349', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2480, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:23.483', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2481, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.191', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2482, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.237', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2483, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2484, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.327', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2485, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.368', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2486, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260521082323-61f4)', '2026-05-21 08:23:24.412', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2487, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:24.857', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2488, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.570', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2489, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.606', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2490, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.640', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2491, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.663', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2492, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.683', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2493, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.718', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2494, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.767', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2495, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.830', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2496, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.905', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2497, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.935', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2498, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:25.966', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2499, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.005', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2500, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.034', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2501, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.061', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2502, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.085', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2503, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.113', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2504, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.151', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2505, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.194', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2506, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260521083724-6645)', '2026-05-21 08:37:26.229', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2507, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.350', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2508, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.394', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2509, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.466', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2510, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.493', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2511, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.511', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2512, 14, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.549', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2513, 1005, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.596', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2514, 1, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.631', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2515, 1017, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.657', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2516, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.692', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2517, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.717', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2518, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.743', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2519, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.761', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2520, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260521084002-0314)', '2026-05-21 08:40:02.783', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2521, 1008, 1025, -4.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.680', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2522, 21, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.770', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2523, 1034, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.805', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2524, 4, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.837', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2525, 1023, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.863', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2526, 1024, 1025, -4.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.880', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2527, 1064, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.897', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2528, 5, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.917', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2529, 1042, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2530, 12, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:16.979', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2531, 2, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260521090116-4c53)', '2026-05-21 09:01:17.002', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2532, 1, 1009, -0.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.493', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2533, 1005, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.707', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2534, 14, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.728', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2535, 3, 3, -2.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.759', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2536, 1, 3, -2.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.814', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2537, 2, 3, -2.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.837', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2538, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.862', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2539, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.891', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2540, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.914', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2541, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.934', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2542, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2543, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.963', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2544, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:18.985', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2545, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.005', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2546, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.029', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2547, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.058', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2548, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.088', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2549, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.117', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2550, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.145', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2551, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.216', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2552, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.232', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2553, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.247', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2554, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.269', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2555, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2556, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260521094818-edf4)', '2026-05-21 09:48:19.322', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2557, 8, NULL, 100.00, N'Nh?p', '2026-05-22 09:28:18.429', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2558, 1018, NULL, 55.00, N'nh?p', '2026-05-22 09:33:01.612', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2559, 1061, NULL, 35.00, N'Nh?p', '2026-05-22 09:33:14.215', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2560, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.653', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2561, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.782', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2562, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.806', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2563, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.846', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2564, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.887', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2565, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.914', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2566, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.957', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2567, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260522093658-3e49)', '2026-05-22 09:36:58.984', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2568, 1008, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.002', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2569, 21, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.073', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2570, 1034, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.095', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2571, 4, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.120', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2572, 1023, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.139', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2573, 1024, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.164', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2574, 1064, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.198', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2575, 5, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.227', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2576, 1042, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.252', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2577, 12, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.277', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2578, 2, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.303', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2579, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.334', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2580, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.369', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2581, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.395', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2582, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.419', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2583, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.437', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2584, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.461', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2585, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.484', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2586, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.512', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2587, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.552', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2588, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.590', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2589, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.619', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2590, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.637', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2591, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.656', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2592, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.682', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2593, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.720', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2594, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.760', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2595, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.788', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2596, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.807', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2597, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.826', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2598, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.854', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2599, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.874', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2600, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.904', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2601, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.939', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2602, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.965', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2603, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:55.993', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2604, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:56.049', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2605, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:56.079', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2606, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:56.101', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2607, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522093754-bd07)', '2026-05-22 09:37:56.124', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2611, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:21.837', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2612, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:21.877', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2613, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:21.898', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2614, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:21.928', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2615, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:21.983', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2616, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.006', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2617, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.027', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2618, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.048', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2619, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.068', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2620, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.102', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2621, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.120', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2622, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.141', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2623, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.168', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2624, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.194', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2625, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.216', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2626, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2627, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.252', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2628, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.268', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2629, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.286', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2630, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.306', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2631, 14, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.336', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2632, 1005, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.372', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2633, 1, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.396', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2634, 1017, 1010, -1.00, N'Xu?t kho cho combo Combo Mix t?ng H?p  (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.415', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2635, 1, 1009, -0.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.444', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2636, 1005, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.464', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2637, 14, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.488', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2638, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.515', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2639, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.546', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2640, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.571', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2641, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.598', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2642, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.629', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2643, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.650', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2644, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.670', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2645, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260522094721-11c8)', '2026-05-22 09:47:22.700', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2646, 1064, NULL, 55.00, N'Nh?p', '2026-05-22 09:48:22.174', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2647, 15, NULL, 15.00, N'Nh?p', '2026-05-22 09:48:34.586', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2648, 1007, NULL, 35.00, N'Nh?p', '2026-05-22 09:48:45.045', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2649, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.753', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2650, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.797', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2651, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2652, 1038, 1024, -2.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.853', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2653, 2, 1024, -3.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.887', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2654, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.918', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2655, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.939', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2656, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:46.974', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2657, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.014', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2658, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.049', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2659, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.080', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2660, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.134', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2661, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.150', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2662, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.177', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2663, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.206', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2664, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2665, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.249', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2666, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.275', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2667, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.294', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2668, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.313', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2669, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.331', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2670, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.349', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2671, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.376', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2672, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.404', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2673, 12, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2674, 1023, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.455', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2675, 21, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.472', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2676, 1044, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.494', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2677, 1065, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.518', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2678, 1064, 1016, -2.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260522095046-75ec)', '2026-05-22 09:50:47.554', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2679, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:49.258', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2680, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.551', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2681, 1008, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.616', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2682, 21, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.772', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2683, 1034, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2684, 4, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.861', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2685, 1023, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:50.940', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2686, 1024, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.045', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2687, 1064, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.097', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2688, 5, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.144', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2689, 1042, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.188', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2690, 12, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.241', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2691, 2, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.305', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2692, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.364', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2693, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2694, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.548', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2695, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.586', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2696, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.632', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2697, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.749', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2698, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.800', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2699, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.863', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2700, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.914', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2701, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260522214249-7891)', '2026-05-22 21:42:51.971', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2702, 14, NULL, 55.00, N'Nh?p', '2026-05-22 21:44:47.455', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2703, 1047, NULL, 95.00, N'Nh?p', '2026-05-22 21:44:59.490', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2704, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:08.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2705, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:08.983', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2706, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.038', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2707, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.127', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2708, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.195', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2709, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2710, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2711, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.393', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2712, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.427', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2713, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.468', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2714, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.506', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2715, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.532', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2716, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.558', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2717, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.582', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2718, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.607', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2719, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.628', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2720, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.647', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2721, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.684', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2722, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.739', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2723, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.757', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2724, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.777', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2725, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.816', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2726, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.855', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2727, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.887', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2728, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.918', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2729, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2730, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.971', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2731, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:09.988', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2732, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.021', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2733, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.043', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2734, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.081', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2735, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.120', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2736, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.155', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2737, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.183', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2738, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.212', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2739, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.236', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2740, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.261', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2741, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260523203008-5971)', '2026-05-23 20:30:10.280', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2793, 1012, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:31.485', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2794, 1013, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.006', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2795, 1, 1028, -1.50, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.047', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2796, 1009, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.083', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2797, 1007, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.125', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2798, 1017, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.154', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2799, 1033, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.251', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2800, 1020, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.280', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2801, 1034, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.310', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2802, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.354', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2803, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.394', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2804, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260523210631-4869)', '2026-05-23 21:06:32.420', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2805, 1084, NULL, 55.00, N'Nh?p', '2026-05-23 21:07:13.863', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2806, 1076, NULL, 55.00, N'Nh?p', '2026-05-23 21:07:26.905', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2807, 1077, NULL, 100.00, N'Nh?p', '2026-05-23 21:07:35.969', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2808, 1078, NULL, 50.00, N'Nh?p', '2026-05-23 21:07:47.562', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2809, 1079, NULL, 25.00, N'Nh?p', '2026-05-23 21:08:00.264', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2810, 1083, NULL, 55.00, N'Nh?p', '2026-05-23 21:08:13.975', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2811, 1082, NULL, 25.00, N'Nh?p', '2026-05-23 21:08:26.269', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2812, 1081, NULL, 20.00, N'Nh?p', '2026-05-23 21:08:35.709', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2813, 1080, NULL, 50.00, N'Nh?p', '2026-05-23 21:08:45.057', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2814, 18, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.003', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2815, 1, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.039', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2816, 6, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.069', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2817, 1021, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.097', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2818, 1005, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.130', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2819, 1017, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.155', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2820, 1009, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2821, 1, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.224', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2822, 1012, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.261', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2823, 1045, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.291', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2824, 14, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.313', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2825, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.341', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2826, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.365', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2827, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.381', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2828, 21, 1030, -1.50, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.407', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2829, 5, 1030, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.453', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2830, 1074, 1026, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.487', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2831, 1026, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.521', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2832, 1028, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.551', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2833, 1043, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.571', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2834, 1067, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.588', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2835, 1044, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523211107-bf9d)', '2026-05-23 21:11:08.605', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2836, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.459', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2837, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.813', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2838, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.840', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2839, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.866', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2840, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.892', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2841, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2842, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.969', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2843, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:05.993', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2844, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.035', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2845, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.092', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2846, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.112', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2847, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.136', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2848, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.163', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2849, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.190', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2850, 1009, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.233', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2851, 1, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.264', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2852, 1012, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2853, 1045, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.324', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2854, 14, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.348', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2855, 21, 1030, -1.50, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.406', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2856, 5, 1030, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.456', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2857, 18, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.499', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2858, 1, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.558', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2859, 6, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.586', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2860, 1021, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2861, 1005, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.740', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2862, 1017, 1033, -1.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260523212605-1487)', '2026-05-23 21:26:06.798', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2863, 11, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:30.199', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2864, 9, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:30.821', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2865, 13, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.006', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2866, 18, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.063', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2867, 15, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.155', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2868, 6, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.204', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2869, 1009, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.270', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2870, 1017, 1005, -2.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.369', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2871, 10, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.473', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2872, 19, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.668', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2873, 1070, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.752', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2874, 1071, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.808', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2875, 1006, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.861', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2876, 6, 2, -2.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260523213029-f926)', '2026-05-23 21:30:31.965', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2877, 14, 1003, -4.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:32.791', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2878, 1019, 1003, -0.40, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:32.956', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2879, 1005, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.017', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2880, 9, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.081', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2881, 8, 4, -4.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.202', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2882, 10, 4, -4.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.407', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2883, 9, 7, -2.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.465', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2884, 1007, 7, -2.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.540', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2885, 14, 7, -2.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.618', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2886, 7, 7, -3.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260523213132-55bc)', '2026-05-23 21:31:33.674', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2887, 7, NULL, 55.00, N'Nh?p', '2026-05-23 21:32:21.012', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2888, 1005, NULL, 100.00, N'Nh?p', '2026-05-23 21:32:34.694', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2889, 11, NULL, 45.00, N'Nh?p', '2026-05-23 21:32:42.464', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2890, 5, NULL, 34.00, N'Nh?p', '2026-05-23 22:02:03.518', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2891, 2, NULL, 23.20, N'Nh?p', '2026-05-23 22:02:22.065', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2892, 1077, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.036', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2893, 1016, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.283', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2894, 7, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.327', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2895, 1018, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.367', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2896, 1037, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.408', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2897, 1022, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2898, 1029, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.482', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2899, 1033, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.520', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2900, 1025, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.559', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2901, 1036, 1038, -2.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.591', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2902, 2, 1037, -3.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.641', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2903, 1013, 1037, -2.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.695', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2904, 5, 1037, -2.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.720', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2905, 14, 1037, -2.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.747', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2906, 3, 1037, -2.80, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.787', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2907, 1007, 1037, -2.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2908, 19, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.869', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2909, 1, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.926', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2910, 14, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2911, 1010, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.974', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2912, 8, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:03.997', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2913, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.038', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2914, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.082', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2915, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.119', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2916, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.164', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2917, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.198', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2918, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.230', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2919, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.332', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2920, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.380', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2921, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:04.978', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2922, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.019', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2923, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.121', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2924, 1074, 1026, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.168', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2925, 1026, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.202', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2926, 1028, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.221', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2927, 1043, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.243', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2928, 1067, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.277', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2929, 1044, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.311', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2930, 1008, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.337', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2931, 21, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.364', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2932, 1034, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.385', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2933, 4, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.404', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2934, 1023, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.424', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2935, 1024, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.444', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2936, 1064, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.462', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2937, 5, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.481', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2938, 1042, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.502', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2939, 12, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.531', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2940, 2, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220702-d152)', '2026-05-23 22:07:05.554', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2963, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:21.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2964, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:21.895', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2965, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:21.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2966, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:21.966', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2967, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:21.996', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2968, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.036', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2969, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.074', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2970, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.094', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2971, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.117', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2972, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.141', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2973, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.165', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2974, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.191', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2975, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.217', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2976, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.236', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2977, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.258', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2978, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.277', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2979, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2980, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.322', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2981, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.348', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2982, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.364', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2983, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.392', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2984, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.414', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2985, 1009, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.440', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2986, 1007, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.466', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2987, 1017, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.486', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2988, 1033, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.508', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2989, 1020, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.528', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2990, 1034, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.548', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2991, 1008, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.578', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2992, 21, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.604', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2993, 1034, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.629', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2994, 4, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.649', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2995, 1023, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2996, 1024, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2997, 1064, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.707', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2998, 5, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.730', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (2999, 1042, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.749', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3000, 12, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.768', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3001, 2, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260523220821-eb78)', '2026-05-23 22:08:22.788', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3002, 1, NULL, 30.10, N'Nh?p', '2026-05-23 22:10:02.413', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3003, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.121', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3004, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.637', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3005, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3006, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.723', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3007, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.762', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3008, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.802', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3009, 19, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.872', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3010, 1, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:37.967', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3011, 14, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.038', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3012, 1010, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.070', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3013, 8, 1036, -2.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.098', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3014, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.151', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3015, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.236', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3016, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.298', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3017, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.329', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3018, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.362', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3019, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225037-8a54)', '2026-05-23 22:50:38.392', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3020, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:13.850', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3021, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:13.910', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3022, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:13.950', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3023, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:13.996', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3024, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.034', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3025, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.065', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3026, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.107', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3027, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.165', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3028, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.223', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3029, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.267', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3030, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.302', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3031, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.340', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3032, 1077, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.409', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3033, 1016, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.478', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3034, 7, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.516', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3035, 1018, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.568', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3036, 1037, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.606', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3037, 1022, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.645', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3038, 1029, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.683', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3039, 1033, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.732', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3040, 1025, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.781', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3041, 1036, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260523225113-1b8c)', '2026-05-23 22:51:14.821', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3042, 1036, NULL, 34.20, N'Nh?p', '2026-05-23 22:52:17.065', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3043, 1, NULL, 4.00, N'Nh?p', '2026-05-23 23:32:40.337', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3044, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:23.316', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3045, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.324', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3046, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.368', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3047, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.443', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3048, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.644', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3049, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.700', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3050, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.743', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3051, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.801', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3052, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.874', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3053, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3054, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.963', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3055, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:24.996', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3056, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.022', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3057, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.083', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3058, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.146', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3059, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.209', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3060, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.246', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (3061, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260524223123-7c27)', '2026-05-24 22:31:25.272', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4044, 18, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:14.982', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4045, 1, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.351', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4046, 6, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.416', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4047, 1021, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.440', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4048, 1005, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.461', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4049, 1017, 1033, -2.00, N'Xu?t kho cho combo Combo Rau C? N?m Cà Ri (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.478', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4050, 1009, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.540', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4051, 1, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.603', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4052, 1012, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.627', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4053, 1045, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.646', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4054, 14, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4055, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.718', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4056, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.756', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4057, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.787', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4058, 21, 1030, -1.50, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.830', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4059, 5, 1030, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.865', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4060, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.893', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4061, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.914', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4062, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4063, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.962', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4064, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:15.994', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4065, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.015', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4066, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.034', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4067, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.051', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4068, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.072', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4069, 1074, 1026, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.099', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4070, 1026, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.128', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4071, 1028, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.146', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4072, 1043, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.164', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4073, 1067, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.187', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4074, 1044, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.210', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4075, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.238', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4076, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.263', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4077, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.287', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4078, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.307', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4079, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.326', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4080, 1012, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.351', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4081, 1013, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.380', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4082, 1, 1028, -1.50, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.397', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4083, 1009, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.430', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4084, 1007, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.463', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4085, 1017, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.483', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4086, 1033, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.502', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4087, 1020, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.520', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4088, 1034, 1029, -1.00, N'Xu?t kho cho combo Combo Nông S?n Theo Tu?n (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.543', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4089, 4, 1023, -1.50, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.575', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4090, 12, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.610', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4091, 1034, 1023, -1.00, N'Xu?t kho cho combo Combo Sinh T? Detox (Ðon: ORD-20260525094614-1694)', '2026-05-25 09:46:16.630', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4092, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:02.437', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4093, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.542', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4094, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.598', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4095, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.688', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4096, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.756', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4097, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.790', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4098, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.818', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4099, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.860', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4100, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.936', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4101, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:03.990', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4102, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:04.029', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4103, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:04.055', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4104, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260525183101-b041)', '2026-05-25 18:31:04.075', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4105, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.413', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4106, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.450', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4107, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.477', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4108, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.511', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4109, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.534', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4110, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.549', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4111, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.566', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4112, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.590', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4113, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.611', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4114, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.631', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4115, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.662', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4116, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.690', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4117, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.710', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4118, 1061, 1015, -2.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.739', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4119, 8, 1015, -1.00, N'Xu?t kho cho combo Como Rau Bí Xào T?i (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.761', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4120, 12, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.793', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4121, 1023, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.830', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4122, 21, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.860', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4123, 1044, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.888', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4124, 1065, 1016, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.906', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4125, 1064, 1016, -2.00, N'Xu?t kho cho combo Combo Nu?c Ép Hoa Qu? 1 (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.925', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4126, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.950', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4127, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:10.981', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4128, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.011', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4129, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.029', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4130, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.050', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4131, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.080', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4132, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.112', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4133, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.141', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4134, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.155', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4135, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.175', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4136, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.195', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4137, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.216', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4138, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.237', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4139, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.269', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4140, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4141, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.328', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4142, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.359', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4143, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.388', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4144, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.413', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4145, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.427', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4146, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.445', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4147, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.474', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4148, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.494', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4149, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.513', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4150, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.544', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4151, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.578', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4152, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260525183210-0690)', '2026-05-25 18:32:11.604', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4153, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:11.340', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4154, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.424', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4155, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4156, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.501', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4157, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.525', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4158, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.553', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4159, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.576', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4160, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.601', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4161, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.666', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4162, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.723', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4163, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.745', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4164, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.781', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4165, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.816', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4166, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.847', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4167, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.867', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4168, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260525215011-a5dc)', '2026-05-25 21:50:13.892', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4169, 6, NULL, 25.00, N'Nh?p', '2026-05-25 21:54:47.551', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4170, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:54.445', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4171, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:55.985', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4172, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:56.028', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4173, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:56.089', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4174, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:56.196', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4175, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527161353-9c96)', '2026-05-27 16:13:56.239', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4176, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:54.498', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4177, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:54.879', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4178, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:54.924', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4179, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:54.949', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4180, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.025', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4181, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.093', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4182, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.130', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4183, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.164', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4184, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.190', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4185, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.256', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4186, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.315', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4187, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.356', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4188, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.405', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4189, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.437', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4190, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.462', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4191, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.492', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4192, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.531', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4193, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.572', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4194, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.612', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4195, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.654', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4196, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.679', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4197, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527221954-7f97)', '2026-05-27 22:19:55.707', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4198, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:30.932', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4199, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.220', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4200, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.265', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4201, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.338', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4202, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.409', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4203, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.439', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4204, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.493', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4205, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.542', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4206, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.590', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4207, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.634', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4208, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.665', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4209, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.695', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4210, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527222530-b9b4)', '2026-05-27 22:25:31.733', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4211, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:45.687', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4212, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:45.867', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4213, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:45.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4214, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:45.977', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4215, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.013', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4216, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.077', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4217, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4218, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.232', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4219, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.269', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4220, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.302', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4221, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.332', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4222, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.363', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4223, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.399', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4224, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.433', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4225, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4226, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.477', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4227, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260527223545-91e2)', '2026-05-27 22:35:46.507', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4228, 1017, NULL, 45.00, N'Nh?p', '2026-05-27 22:36:27.574', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4229, 1006, NULL, 55.00, N'Nh?p', '2026-05-27 22:36:37.858', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4230, 9, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527225313-fb06)', '2026-05-27 22:53:13.396', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4231, 8, 4, -4.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527225313-fb06)', '2026-05-27 22:53:13.690', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4232, 10, 4, -4.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260527225313-fb06)', '2026-05-27 22:53:13.732', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4233, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.114', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4234, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.524', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4235, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.567', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4236, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.608', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4237, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.640', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4238, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.716', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4239, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.761', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4240, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.809', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4241, 1006, 1004, -1.00, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.900', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4242, 1019, 1004, -0.30, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:34.974', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4243, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:35.023', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4244, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:35.065', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4245, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260527230333-572a)', '2026-05-27 23:03:35.110', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4246, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:51.498', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4247, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.298', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4248, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.354', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4249, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.404', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4250, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.462', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4251, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.575', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4252, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.626', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4253, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.653', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4254, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.688', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4255, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.733', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4256, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.777', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4257, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528173751-2863)', '2026-05-28 17:37:52.825', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4258, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.064', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4259, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.379', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4260, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.412', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4261, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.459', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4262, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.590', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4263, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.691', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4264, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.872', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4265, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:30.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4266, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.153', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4267, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.239', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4268, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.348', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4269, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.458', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4270, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.488', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4271, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.536', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4272, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.651', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4273, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528173829-2f2d)', '2026-05-28 17:38:31.789', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4274, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:42.904', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4275, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.061', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4276, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.103', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4277, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.151', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4278, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.187', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4279, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.218', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4280, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.264', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4281, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.402', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4282, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.450', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4283, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.474', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4284, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.507', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4285, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.551', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4286, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.623', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4287, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4288, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.717', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4289, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.736', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4290, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528173942-5ddc)', '2026-05-28 17:39:43.764', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4291, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:37.116', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4292, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:37.168', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4293, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:37.218', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4294, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:37.243', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4295, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.720', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4296, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.757', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4297, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.785', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4298, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.812', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4299, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.834', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4300, 1074, 1026, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.873', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4301, 1026, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.911', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4302, 1028, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.937', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4303, 1043, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.967', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4304, 1067, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:40.987', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4305, 1044, 1026, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? Mix Theo Tu?n (Ðon: ORD-20260528174037-15b7)', '2026-05-28 17:40:41.021', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4306, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.266', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4307, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.394', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4308, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.423', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4309, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.470', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4310, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.524', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4311, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.560', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4312, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528174259-422c)', '2026-05-28 17:42:59.583', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4313, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174403-8090)', '2026-05-28 17:44:03.056', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4314, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174403-8090)', '2026-05-28 17:44:03.113', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4315, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174403-8090)', '2026-05-28 17:44:03.148', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4316, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174403-8090)', '2026-05-28 17:44:03.178', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4317, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174403-8090)', '2026-05-28 17:44:03.210', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4318, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.547', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4319, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.598', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4320, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.656', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4321, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.701', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4322, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.736', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4323, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.773', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4324, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.798', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4325, 1008, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.853', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4326, 21, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.881', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4327, 1034, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.898', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4328, 4, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4329, 1023, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4330, 1024, 1025, -2.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.967', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4331, 1064, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:40.991', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4332, 5, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.023', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4333, 1042, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.055', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4334, 12, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.084', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4335, 2, 1025, -1.00, N'Xu?t kho cho combo Combo Smothie Theo Tu?n (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.114', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4336, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.149', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4337, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4338, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528174440-1041)', '2026-05-28 17:44:41.200', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4339, 1020, NULL, 55.00, N'Nh?p', '2026-05-28 17:45:51.664', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4340, 1009, NULL, 145.00, N'Nh?p', '2026-05-28 17:46:04.750', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4341, 10, NULL, 32.00, N'Nh?p', '2026-05-28 17:46:14.809', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4342, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.438', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4343, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.630', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4344, 1064, 1019, -1.10, N'Xu?t kho cho combo Combo Smothie Gi?m Cân 1 (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.676', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4345, 1023, 1019, -1.00, N'Xu?t kho cho combo Combo Smothie Gi?m Cân 1 (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.726', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4346, 1034, 1019, -1.00, N'Xu?t kho cho combo Combo Smothie Gi?m Cân 1 (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.757', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4347, 21, 1019, -1.50, N'Xu?t kho cho combo Combo Smothie Gi?m Cân 1 (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.789', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4348, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.824', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4349, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260528174919-2779)', '2026-05-28 17:49:19.857', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4350, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.050', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4351, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.088', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4352, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.121', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4353, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.149', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4354, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.189', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4355, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.215', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4356, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.243', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4357, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.268', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4358, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.313', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4359, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.349', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4360, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.379', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4361, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.418', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4362, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528174950-917a)', '2026-05-28 17:49:50.452', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4363, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.846', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4364, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.877', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4365, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.899', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4366, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.921', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4367, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4368, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:22.984', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4369, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:23.024', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4370, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528175022-6db3)', '2026-05-28 17:50:23.049', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4371, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.197', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4372, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.264', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4373, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.306', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4374, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.335', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4375, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.363', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4376, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528175209-702c)', '2026-05-28 17:52:09.386', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4377, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:46.887', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4378, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:46.930', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4379, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:46.956', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4380, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.008', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4381, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.061', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4382, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.092', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4383, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.112', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4384, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.128', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4385, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.155', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4386, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4387, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.207', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4388, 1006, 1004, -1.00, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.244', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4389, 1019, 1004, -0.30, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.282', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4390, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.321', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4391, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.357', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4392, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.381', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4393, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528175246-3048)', '2026-05-28 17:52:47.401', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4394, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:20.856', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4395, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:20.894', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4396, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:20.912', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4397, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:20.931', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4398, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:20.973', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4399, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:21.012', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4400, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528175320-93c9)', '2026-05-28 17:53:21.034', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4401, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.117', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4402, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.169', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4403, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.214', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4404, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.248', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4405, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.285', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4406, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.311', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4407, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.338', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4408, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.365', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4409, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.405', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4410, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4411, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.491', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4412, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.525', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4413, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260528175405-b949)', '2026-05-28 17:54:05.563', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4414, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:52.922', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4415, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:52.977', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4416, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:52.994', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4417, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:53.012', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4418, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:53.031', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4419, 1012, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:53.060', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4420, 1013, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:53.101', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4421, 1, 1028, -1.50, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260528175652-141c)', '2026-05-28 17:56:53.130', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4422, 1, NULL, 100.00, N'Nh?p', '2026-05-28 17:57:26.210', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4423, 15, NULL, 25.00, N'Nh?p', '2026-05-28 17:57:36.012', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4424, 13, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.088', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4425, 1022, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.251', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4426, 1036, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.305', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4427, 1034, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.359', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4428, 1048, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.389', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4429, 1009, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.426', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4430, 1030, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.493', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4431, 1020, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.519', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4432, 1032, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.576', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4433, 1049, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.602', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4434, 1030, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.642', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4435, 1031, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.673', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4436, 1007, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.690', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4437, 1061, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.709', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4438, 18, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.732', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4439, 1012, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182057-df5f)', '2026-05-28 18:20:57.755', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4440, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:40.997', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4441, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.038', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4442, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.067', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4443, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.111', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4444, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.144', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4445, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.164', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4446, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.186', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4447, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.221', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4448, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.241', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4449, 1077, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.266', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4450, 1016, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.298', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4451, 7, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.330', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4452, 1018, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.353', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4453, 1037, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.376', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4454, 1022, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.402', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4455, 1029, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.444', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4456, 1033, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.475', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4457, 1025, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.498', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4458, 1036, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.525', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4459, 1040, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.564', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4460, 1044, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.595', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4461, 1024, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.622', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4462, 1041, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.650', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4463, 1043, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4464, 1057, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.722', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4465, 1065, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.759', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4466, 1080, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528182140-8b7a)', '2026-05-28 18:21:41.789', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4467, 4, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.605', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4468, 12, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.632', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4469, 1044, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.645', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4470, 1064, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.665', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4471, 21, 1011, -1.00, N'Xu?t kho cho combo Combo Smothie (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.683', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4472, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.720', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4473, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.758', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4474, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260528182223-dd60)', '2026-05-28 18:22:23.785', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4475, 1082, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.396', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4476, 1066, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.426', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4477, 1041, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.451', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4478, 1042, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.484', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4479, 1074, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.516', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4480, 1069, 1042, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.546', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4481, 1030, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.576', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4482, 1031, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.608', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4483, 1007, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.629', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4484, 1061, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.653', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4485, 18, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.675', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4486, 1012, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528182258-4152)', '2026-05-28 18:22:58.702', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4487, 1082, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.553', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4488, 1066, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.617', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4489, 1041, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.657', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4490, 1042, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.680', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4491, 1074, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.706', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4492, 1069, 1042, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.732', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4493, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.768', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4494, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.818', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4495, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.851', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4496, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528182525-f4b1)', '2026-05-28 18:25:25.877', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4497, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.212', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4498, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.262', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4499, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.294', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4500, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.370', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4501, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.429', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4502, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.475', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4503, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.508', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4504, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.547', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4505, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260528182603-c626)', '2026-05-28 18:26:03.585', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4506, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.568', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4507, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.606', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4508, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.625', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4509, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.645', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4510, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.667', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4511, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.700', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4512, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.735', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4513, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.766', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4514, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.808', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4515, 2, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.851', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4516, 5, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.890', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4517, 1033, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.909', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4518, 1008, 1013, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.933', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4519, 1038, 1013, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân (Ðon: ORD-20260528182641-a3f3)', '2026-05-28 18:26:41.959', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4520, 1075, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.768', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4521, 1051, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.802', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4522, 1053, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.827', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4523, 1072, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.860', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4524, 1058, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.887', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4525, 1021, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.918', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4526, 1084, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4527, 1059, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:23.971', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4528, 21, 1030, -1.50, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.005', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4529, 5, 1030, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.049', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4530, 2, 1034, -1.50, N'Xu?t kho cho combo Combo Rau C? Cu?n Bánh Tráng (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.085', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4531, 1, 1034, -1.50, N'Xu?t kho cho combo Combo Rau C? Cu?n Bánh Tráng (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.123', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4532, 1013, 1034, -1.00, N'Xu?t kho cho combo Combo Rau C? Cu?n Bánh Tráng (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.148', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4533, 21, 1034, -1.00, N'Xu?t kho cho combo Combo Rau C? Cu?n Bánh Tráng (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.173', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4534, 1063, 1034, -1.00, N'Xu?t kho cho combo Combo Rau C? Cu?n Bánh Tráng (Ðon: ORD-20260528182723-9db2)', '2026-05-28 18:27:24.206', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4535, 2, NULL, 55.00, N'nh?p', '2026-05-28 18:28:52.156', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4536, 19, NULL, 100.00, N'Nh?p', '2026-05-28 18:29:15.709', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4537, 19, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:49.821', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4538, 10, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:49.891', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4539, 6, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:49.936', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4540, 1016, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:49.979', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4541, 20, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.021', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4542, 1021, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.046', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4543, 1062, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.072', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4544, 1055, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.100', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4545, 1056, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.122', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4546, 1033, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.156', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4547, 1035, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.200', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4548, 1045, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.223', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4549, 1048, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.251', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4550, 1005, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.271', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4551, 1060, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.301', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4552, 1075, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.343', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4553, 1051, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.379', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4554, 1053, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.407', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4555, 1072, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.440', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4556, 1058, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.458', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4557, 1021, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.474', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4558, 1084, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.491', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4559, 1059, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260528184549-1dc1)', '2026-05-28 18:45:50.519', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4560, 1082, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.074', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4561, 1066, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.131', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4562, 1041, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4563, 1042, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.221', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4564, 1074, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.247', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4565, 1069, 1042, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528184628-8de9)', '2026-05-28 18:46:28.270', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4566, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.420', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4567, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.471', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4568, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.490', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4569, 10, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.525', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4570, 19, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.573', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4571, 1070, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.600', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4572, 1071, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.623', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4573, 1006, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.641', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4574, 6, 2, -1.00, N'Xu?t kho cho combo Combo Canh N?m (Ðon: ORD-20260528184708-af95)', '2026-05-28 18:47:08.676', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4575, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.403', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4576, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.445', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4577, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.470', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4578, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.494', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4579, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.521', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4580, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.559', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4581, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.605', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4582, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.646', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4583, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.674', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4584, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.695', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4585, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260528184742-ac3e)', '2026-05-28 18:47:42.722', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4586, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:53.906', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4587, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:53.939', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4588, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:53.985', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4589, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:54.065', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4590, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:54.090', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4591, 3, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:54.121', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4592, 1, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:54.153', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4593, 2, 3, -1.00, N'Xu?t kho cho combo Combo Salad (Ðon: ORD-20260528184953-c773)', '2026-05-28 18:49:54.173', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4594, 1030, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.473', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4595, 1031, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.501', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4596, 1007, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.518', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4597, 1061, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.546', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4598, 18, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.571', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4599, 1012, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.588', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4600, 1040, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.614', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4601, 1044, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.656', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4602, 1024, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.700', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4603, 1041, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.725', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4604, 1043, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.755', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4605, 1057, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.781', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4606, 1065, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.807', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4607, 1080, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260528185046-abac)', '2026-05-28 18:50:46.826', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4608, 11, 1014, -4.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.294', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4609, 1032, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.322', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4610, 1047, 1014, -6.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.341', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4611, 1045, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.363', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4612, 1016, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.442', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4613, 21, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.470', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4614, 17, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.490', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4615, 10, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.524', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4616, 1018, 1014, -1.00, N'Xu?t kho cho combo Combo Mix 2 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.547', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4617, 1, 1009, -0.50, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.579', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4618, 1005, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.617', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4619, 14, 1009, -2.00, N'Xu?t kho cho combo Combo Mix 1 (Ðon: ORD-20260528185125-8720)', '2026-05-28 18:51:25.638', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4620, 19, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.386', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4621, 10, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.551', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4622, 6, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.593', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4623, 1016, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.628', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4624, 20, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.656', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4625, 1021, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.680', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4626, 1062, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.702', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4627, 1055, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.726', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4628, 1056, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.752', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4629, 1082, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.788', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4630, 1066, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.866', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4631, 1041, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.904', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4632, 1042, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4633, 1074, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.964', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4634, 1069, 1042, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:31.987', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4635, 1, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.022', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4636, 1006, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.074', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4637, 7, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.104', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4638, 1017, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.129', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4639, 1022, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.154', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4640, 1072, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528191331-f193)', '2026-05-28 19:13:32.185', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4641, 1038, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.284', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4642, 1014, 1022, -1.00, N'Xu?t kho cho combo Combo Detox Chanh G?ng (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.325', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4643, 5, 1017, -2.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.360', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4644, 1064, 1017, -1.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.400', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4645, 1008, 1017, -3.00, N'Xu?t kho cho combo Combo Detox Gi?m Cân 1 (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.424', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4646, 1038, 1024, -1.00, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.468', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4647, 2, 1024, -1.50, N'Xu?t kho cho combo Combo Detox Chanh Và Dua Chu?t (Ðon: ORD-20260528191410-d5ee)', '2026-05-28 19:14:10.505', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4648, 2, 1037, -1.50, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.131', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4649, 1013, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.170', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4650, 5, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.199', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4651, 14, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.221', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4652, 3, 1037, -1.40, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.257', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4653, 1007, 1037, -1.00, N'Xu?t kho cho combo Combo Rau C? An Kiêng (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.285', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4654, 19, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.318', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4655, 1, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.352', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4656, 14, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.392', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4657, 1010, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.416', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4658, 8, 1036, -1.00, N'Xu?t kho cho combo Combo Rau C? S?t Bo T?i (Ðon: ORD-20260528191445-c604)', '2026-05-28 19:14:45.438', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4659, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528191525-c8b6)', '2026-05-28 19:15:25.230', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4660, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528191525-c8b6)', '2026-05-28 19:15:25.263', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4661, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260528191525-c8b6)', '2026-05-28 19:15:25.287', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4662, 21, 1030, -1.50, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260528191525-c8b6)', '2026-05-28 19:15:25.333', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4663, 5, 1030, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép Xoài Táo (Ðon: ORD-20260528191525-c8b6)', '2026-05-28 19:15:25.369', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4664, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191606-05dd)', '2026-05-28 19:16:06.552', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4665, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191606-05dd)', '2026-05-28 19:16:06.587', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4666, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191606-05dd)', '2026-05-28 19:16:06.617', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4667, 1077, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.764', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4668, 1023, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.793', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4669, 21, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.885', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4670, 1024, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.923', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4671, 1044, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.947', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4672, 1057, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:02.973', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4673, 1075, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.003', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4674, 1078, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.041', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4675, 1030, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.067', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4676, 1033, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.096', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4677, 1052, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.123', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4678, 1046, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.152', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4679, 1054, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.187', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4680, 1067, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260528191702-732c)', '2026-05-28 19:17:03.230', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4681, 1006, 1004, -1.00, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260528191754-89cc)', '2026-05-28 19:17:54.223', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4682, 1019, 1004, -0.30, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260528191754-89cc)', '2026-05-28 19:17:54.267', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4683, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191754-89cc)', '2026-05-28 19:17:54.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4684, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191754-89cc)', '2026-05-28 19:17:54.327', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4685, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260528191754-89cc)', '2026-05-28 19:17:54.354', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4689, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528192338-ed0d)', '2026-05-28 19:23:38.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4690, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528192338-ed0d)', '2026-05-28 19:23:38.853', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4691, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260528192338-ed0d)', '2026-05-28 19:23:38.893', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4692, 15, 5, -4.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260528192338-ed0d)', '2026-05-28 19:23:38.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4693, 8, 5, -8.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260528192338-ed0d)', '2026-05-28 19:23:39.022', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4694, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.458', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4695, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.570', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4696, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.642', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4697, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.678', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4698, 1, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.724', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4699, 1006, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.757', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4700, 7, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.776', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4701, 1017, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.792', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4702, 1022, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.811', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4703, 1072, 1045, -1.00, N'Xu?t kho cho combo Combo t?ng H?p 3 (Ðon: ORD-20260528192559-bed6)', '2026-05-28 19:25:59.837', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4704, 1048, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:37.989', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4705, 1058, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.128', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4706, 1059, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.137', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4707, 1052, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.147', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4708, 1047, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.160', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4709, 1031, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.168', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4710, 14, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4711, 4, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.189', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4712, 1035, 1050, -2.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.201', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4713, 19, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.218', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4714, 10, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.265', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4715, 6, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.273', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4716, 1016, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.284', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4717, 20, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.294', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4718, 1021, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.304', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4719, 1062, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.315', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4720, 1055, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.391', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4721, 1056, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.402', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4722, 1075, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.417', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4723, 1078, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.431', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4724, 1030, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.443', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4725, 1033, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.453', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4726, 1052, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.465', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4727, 1046, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.472', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4728, 1054, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.484', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4729, 1067, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.495', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4730, 1009, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.510', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4731, 1030, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.530', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4732, 1020, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.539', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4733, 1032, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.550', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4734, 1049, 1043, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.563', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4735, 1030, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.580', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4736, 1031, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.609', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4737, 1007, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.619', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4738, 1061, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.626', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4739, 18, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.647', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4740, 1012, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260529175237-4408)', '2026-05-29 17:52:38.656', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4741, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:50.361', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4742, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.013', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4743, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.070', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4744, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.163', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4745, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.266', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4746, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.304', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4747, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.341', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4748, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.387', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4749, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.455', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4750, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.499', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4751, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.531', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4752, 1048, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.573', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4753, 1058, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.636', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4754, 1059, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.701', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4755, 1052, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.757', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4756, 1047, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.830', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4757, 1031, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:51.999', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4758, 14, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.027', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4759, 4, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.050', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4760, 1035, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.082', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4761, 1077, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.127', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4762, 1023, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.180', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4763, 21, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.224', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4764, 1024, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.250', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4765, 1044, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.350', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4766, 1057, 1048, -1.00, N'Xu?t kho cho combo Sinh T? Mix  (Ðon: ORD-20260530162649-cb38)', '2026-05-30 16:26:52.397', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4767, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:27:58.589', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4768, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:27:59.994', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4769, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.034', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4770, 9, 1035, -0.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.171', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4771, 1006, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.482', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4772, 19, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.781', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4773, 16, 1035, -2.50, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.909', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4774, 1046, 1035, -2.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:00.983', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4775, 1, 1035, -1.00, N'Xu?t kho cho combo Combo Rau C? Chiên Tempura (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.025', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4776, 1077, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4777, 1016, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.382', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4778, 7, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.613', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4779, 1018, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.789', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4780, 1037, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.859', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4781, 1022, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:01.959', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4782, 1029, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:02.131', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4783, 1033, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:02.408', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4784, 1025, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:02.549', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4785, 1036, 1038, -1.00, N'Xu?t kho cho combo Combo Nông S?n t?ng H?p (Ðon: ORD-20260530162758-4509)', '2026-05-30 16:28:02.577', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4786, 9, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:22.525', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4787, 1007, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.251', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4788, 14, 7, -1.00, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.286', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4789, 7, 7, -1.50, N'Xu?t kho cho combo Combo Rau C? Chay Bí ?n (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.315', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4790, 1018, 1012, -1.50, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.376', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4791, 7, 1012, -2.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.472', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4792, 9, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.521', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4793, 1007, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.566', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4794, 8, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.606', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4795, 1010, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.640', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4796, 1012, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.665', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4797, 1020, 1012, -1.00, N'Xu?t kho cho combo Combo Mix Tu?n  (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.693', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4798, 18, 1008, -0.50, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.746', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4799, 1, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.791', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4800, 1009, 1008, -1.00, N'Xu?t kho cho combo Combo Rau C? Kho (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.828', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4801, 1, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.862', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4802, 16, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.896', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4803, 14, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.920', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4804, 1007, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.942', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4805, 9, 1007, -1.00, N'Xu?t kho cho combo Combo An D?m Cho Bé (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:23.967', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4806, 1048, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.001', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4807, 1058, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.059', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4808, 1059, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.189', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4809, 1052, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.296', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4810, 1047, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.337', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4811, 1031, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.372', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4812, 14, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.406', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4813, 4, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.440', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4814, 1035, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.467', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4815, 19, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.510', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4816, 10, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.559', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4817, 6, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.592', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4818, 1016, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.618', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4819, 20, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.650', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4820, 1021, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.682', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4821, 1062, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.732', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4822, 1055, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.778', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4823, 1056, 1047, -1.00, N'Xu?t kho cho combo Combo t?ng H?p Rau Mix N?m (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.825', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4824, 1082, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.877', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4825, 1066, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.916', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4826, 1041, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.948', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4827, 1042, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:24.979', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4828, 1074, 1042, -1.00, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.021', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4829, 1069, 1042, -1.50, N'Xu?t kho cho combo Combo Hoa Qu? 10 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.054', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4830, 1030, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.092', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4831, 1031, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.133', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4832, 1007, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.161', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4833, 1061, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.198', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4834, 18, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.242', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4835, 1012, 1041, -1.00, N'Xu?t kho cho combo Combo Rau Canh Mix (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.276', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4836, 1040, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.325', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4837, 1044, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.368', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4838, 1024, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.413', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4839, 1041, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.448', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4840, 1043, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.492', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4841, 1057, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.544', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4842, 1065, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.585', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4843, 1080, 1040, -1.00, N'Xu?t kho cho combo Combo Hoa Q?a Mix 9 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.633', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4844, 1033, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.672', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4845, 1035, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.714', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4846, 1045, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.751', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4847, 1048, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.787', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4848, 1005, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.827', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4849, 1060, 1046, -1.00, N'Xu?t kho cho combo Combo Chay 1 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.870', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4850, 1075, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.907', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4851, 1078, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.955', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4852, 1030, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:25.996', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4853, 1033, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.028', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4854, 1052, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.066', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4855, 1046, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.097', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4856, 1054, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.128', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4857, 1067, 1049, -1.00, N'Xu?t kho cho combo Package Vegetable (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.158', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4858, 13, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.195', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4859, 1022, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.242', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4860, 1036, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.278', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4861, 1034, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.312', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4862, 1048, 1044, -1.00, N'Xu?t kho cho combo Combo Rau C? t?ng H?p 2 (Ðon: ORD-20260531190022-ce88)', '2026-05-31 19:00:26.343', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4863, 11, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.409', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4864, 9, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.454', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4865, 13, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.477', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4866, 18, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.503', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4867, 15, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.526', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4868, 6, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.556', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4869, 1009, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.579', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4870, 1017, 1005, -1.00, N'Xu?t kho cho combo Combo t?ng H?p (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.605', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4871, 1006, 1004, -1.00, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.634', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4872, 1019, 1004, -0.30, N'Xu?t kho cho combo Combo Cà Tím Xào ?t (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.675', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4873, 14, 1003, -2.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.713', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4874, 1019, 1003, -0.20, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.751', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4875, 1005, 1003, -1.00, N'Xu?t kho cho combo Combo Súp Lo Xào N?m (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.779', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4876, 10, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.822', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4877, 19, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.873', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4878, 1076, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.903', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4879, 1005, 1027, -2.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.940', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4880, 11, 1027, -1.00, N'Xu?t kho cho combo Combo Canh N?m 1 (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.960', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4881, 1012, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:04.989', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4882, 1013, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:05.017', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4883, 1, 1028, -1.50, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531190704-23ff)', '2026-05-31 19:07:05.041', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4884, 1075, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.686', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4885, 1051, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.730', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4886, 1053, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.759', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4887, 1072, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.786', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4888, 1058, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.804', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4889, 1021, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.823', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4890, 1084, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.848', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4891, 1059, 1039, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix 3 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.872', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4892, 1009, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.899', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4893, 1, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.933', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4894, 1012, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.969', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4895, 1045, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:29.999', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4896, 14, 1032, -1.00, N'Xu?t kho cho combo Combo Rau C? Lu?c (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.026', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4897, 1064, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.069', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4898, 1023, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.101', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4899, 1, 1031, -1.00, N'Xu?t kho cho combo Combo Nu?c Ép 1 (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.128', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4900, 1012, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.170', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4901, 1013, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.200', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4902, 1, 1028, -1.50, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.229', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4903, 3, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.249', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4904, 1044, 1028, -1.00, N'Xu?t kho cho combo Combo Salad Mix (Ðon: ORD-20260531191729-de47)', '2026-05-31 19:17:30.274', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4905, 1, NULL, 0.40, N'Nh?p', '2026-05-31 22:22:56.108', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4906, 1064, 1031, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4907, 1023, 1031, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4908, 1, 1031, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4909, 1009, 1032, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4910, 1, 1032, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4911, 1012, 1032, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4912, 1045, 1032, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4913, 14, 1032, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4914, 1075, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4915, 1051, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4916, 1053, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4917, 1072, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4918, 1058, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4919, 1021, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4920, 1084, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4921, 1059, 1039, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4922, 1012, 1028, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4923, 1013, 1028, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4924, 1, 1028, 1.50, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4925, 3, 1028, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4926, 1044, 1028, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531191729-de47', '2026-05-31 22:23:59.580', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4936, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.064', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4937, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.118', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4938, 1009, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.176', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4939, 1010, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.243', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4940, 1, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.269', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4941, 6, 6, -1.00, N'Xu?t kho cho combo Combo Rau C? Mix (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.300', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4942, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.341', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4943, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.370', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4944, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223342-ae3c)', '2026-05-31 22:33:43.410', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4945, 9, 4, -1.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.534', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4946, 8, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.659', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4947, 10, 4, -2.00, N'Xu?t kho cho combo Combo Canh Bí Ð? (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.681', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4948, 15, 5, -1.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.724', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4949, 8, 5, -2.00, N'Xu?t kho cho combo Combo Rau Mu?ng Xào T?i (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.774', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4950, 1, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.812', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4951, 18, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.848', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4952, 6, 1006, -1.00, N'Xu?t kho cho combo Combo Canh Khoai Tây (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.871', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4953, 1048, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.924', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4954, 1058, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:55.963', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4955, 1059, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.031', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4956, 1052, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.063', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4957, 1047, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.082', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4958, 1031, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.125', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4959, 14, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.149', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4960, 4, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.171', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4961, 1035, 1050, -1.00, N'Xu?t kho cho combo Mix L?n Hoa Qu? và Rau C? 1 (Ðon: ORD-20260531223555-e1a7)', '2026-05-31 22:35:56.201', N'EXPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4962, 9, 4, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:20.807', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4963, 8, 4, 2.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:20.994', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4964, 10, 4, 2.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.017', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4965, 15, 5, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.037', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4966, 8, 5, 2.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.058', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4967, 1, 1006, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.075', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4968, 18, 1006, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.093', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4969, 6, 1006, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.114', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4970, 1048, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.132', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4971, 1058, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.149', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4972, 1059, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.165', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4973, 1052, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.178', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4974, 1047, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.191', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4975, 1031, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.205', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4976, 14, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.218', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4977, 4, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.231', N'IMPORT');
INSERT INTO [InventoryTransactions] ([TransactionId], [InventoryId], [PackageId], [QuantityChange], [Note], [TransactionDate], [TransactionType]) VALUES (4978, 1035, 1050, 1.00, N'Hoàn t?n kho l? do h?y don ORD-20260531223555-e1a7', '2026-05-31 22:42:21.244', N'IMPORT');
SET IDENTITY_INSERT [InventoryTransactions] OFF;

-- Data for table Carts
SET IDENTITY_INSERT [Carts] ON;
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (1, 0.00, 2003);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (3, 0.00, 2005);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (4, 0.00, 2006);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (5, 0.00, 2007);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (6, 0.00, 2008);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (7, 0.00, 2004);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (8, 0.00, 2009);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (9, 0.00, 1002);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (10, 0.00, 2010);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (11, 0.00, 2011);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (12, 0.00, 2012);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (13, 0.00, 2013);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (14, 0.00, 2014);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (15, 0.00, 2015);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (16, 0.00, 2016);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (17, 0.00, 2017);
INSERT INTO [Carts] ([CartId], [TotalPrice], [UserId]) VALUES (18, 0.00, 2019);
SET IDENTITY_INSERT [Carts] OFF;

-- Data for table CartItems
SET IDENTITY_INSERT [CartItems] ON;
INSERT INTO [CartItems] ([CartItemId], [CartId], [CartQuantity], [CartPrice], [PackageId]) VALUES (1060, 8, 2, 15000.00, 4);
INSERT INTO [CartItems] ([CartItemId], [CartId], [CartQuantity], [CartPrice], [PackageId]) VALUES (1061, 8, 1, 15000.00, 4);
INSERT INTO [CartItems] ([CartItemId], [CartId], [CartQuantity], [CartPrice], [PackageId]) VALUES (1062, 8, 4, 6000.00, 5);
INSERT INTO [CartItems] ([CartItemId], [CartId], [CartQuantity], [CartPrice], [PackageId]) VALUES (1063, 8, 4, 35000.00, 3);
INSERT INTO [CartItems] ([CartItemId], [CartId], [CartQuantity], [CartPrice], [PackageId]) VALUES (1064, 8, 4, 35000.00, 2);
SET IDENTITY_INSERT [CartItems] OFF;

-- Data for table Orders
SET IDENTITY_INSERT [Orders] ON;
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1, N'ORD-20260514214207', N'An Nguy?n', N'0397892310', N'Khong co dia chi', '2026-05-14 21:42:07.347', N'Ðã h?y', 0.00, 1002, 0.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2, N'ORD-20260514220152', N'an nguy?n', N'0989767890', N'dai hoc cntt va truyen thong thai nguyen', '2026-05-14 22:01:52.284', N'Hoàn thành', 40000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3, N'ORD-20260514221046', N'hien hien', N'0389012378', N'xã luong nang huy?n van quan t?nh l?ng son', '2026-05-14 22:10:46.355', N'Hoàn thành', 90000.00, 1003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1002, N'ORD-20260515223018-9697', N'Tuoi ', N'0989567313', N'Ð?i h?c thái nguyên', '2026-05-15 22:30:18.882', N'Ðã h?y', 185000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1003, N'ORD-20260515225245-eb0c', N'Tr?n Nam', N'0989345678', N'Ð?i h?c cntt', '2026-05-15 22:52:45.333', N'Hoàn thành', 185000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1004, N'ORD-20260516004842-19b2', N'Quang Nguy?n', N'0366889114', N'Ð?i H?c CNTT', '2026-05-16 00:48:42.409', N'Hoàn thành', 364000.00, 2004, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1005, N'ORD-20260516005414-6950', N'Nguy?n An', N'0912678898', N'Ð?i H?c CNTT', '2026-05-16 00:54:14.420', N'Hoàn thành', 155000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1006, N'ORD-20260516163100-9e2d', N'Phuong Chi', N'0366900231', N'Ð?i H?c CNTT', '2026-05-16 16:31:00.379', N'Hoàn thành', 235000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1007, N'ORD-20260516163211-ea38', N'Nguy?n Minh', N'0966123890', N'Ð?i H?c CNTT', '2026-05-16 16:32:11.685', N'Hoàn thành', 85000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1008, N'ORD-20260516170105-3775', N'Hoàng Chi', N'0989123456', N'Yên Phúc, L?ng Son', '2026-05-16 17:01:05.143', N'Hoàn thành', 344993.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1009, N'ORD-20260516170212-ae89', N'Hoàng Son', N'0390456789', N'Ði?m He, L?ng Son', '2026-05-16 17:02:12.027', N'Hoàn thành', 110000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1010, N'ORD-20260516170307-9094', N'M?nh Huy', N'0398123765', N'Tri L?, L?ng Son', '2026-05-16 17:03:07.848', N'Hoàn thành', 50000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1011, N'ORD-20260516214617-96f1', N'Hoài Nam', N'0912345678', N'Phu?ng Quy?t Th?ng, Thái Nguyên', '2026-05-16 21:46:17.550', N'Hoàn thành', 524996.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1012, N'ORD-20260516214948-c492', N'Qu?c Quang', N'0390123876', N'Xã Tri L?, L?ng Son', '2026-05-16 21:49:48.249', N'Hoàn thành', 125000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1013, N'ORD-20260516220253-12b0', N'Hiên L?c', N'0345678890', N'Ð?i H?c CNTT', '2026-05-16 22:02:53.237', N'Hoàn thành', 269998.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1014, N'ORD-20260516221504-2b15', N'Mai Anh', N'0916321123', N'Xã Yên Phúc, L?ng Son', '2026-05-16 22:15:04.357', N'Hoàn thành', 243000.00, 2008, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1015, N'ORD-20260516224249-346f', N'Mai Lan', N'0981890332', N'Ð?i H?c CNTT', '2026-05-16 22:42:49.071', N'Hoàn thành', 279998.00, 2004, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1016, N'ORD-20260518053922-7c4b', N'Nguy?n Van An', N'0966451243', N'Ð?i H?c CNTT & TT', '2026-05-18 05:39:22.959', N'Hoàn thành', 190000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1017, N'ORD-20260518060326-2732', N'Minh H?ng', N'0968123456', N'Ð?i H?c CNTT', '2026-05-18 06:03:26.038', N'Hoàn thành', 184000.00, 2009, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1018, N'ORD-20260518060419-ee6b', N'Ð? T?t Nghi?p', N'0945677889', N'Ð?i H?c CNTT', '2026-05-18 06:04:19.220', N'Hoàn thành', 125000.00, 2009, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1019, N'ORD-20260519122034-45f7', N'Hoàng Van A', N'0941366799', N'Ð?i H?c CNTT & TT', '2026-05-19 12:20:34.058', N'Hoàn thành', 250000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1020, N'ORD-20260519122503-fe2d', N'Truong Th? Hoa', N'0921344566', N'Ð?i H?c CNTT', '2026-05-19 12:25:03.570', N'Hoàn thành', 245999.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1021, N'ORD-20260520001539-8564', N'Tr?n Van Minh', N'0924166899', N'Ð?i h?c cntt', '2026-05-20 00:15:39.980', N'Ðã h?y', 350000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (1022, N'ORD-20260520004239-8210', N'Dao Hong Ngoc', N'0989123456', N'dai hoc cntt', '2026-05-20 00:42:39.899', N'Ðã h?y', 335000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2020, N'ORD-20260520080242-4b75', N'Lan', N'0935142411', N'Ð?i h?c cntt', '2026-05-20 08:02:42.372', N'Hoàn thành', 100000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2021, N'ORD-20260520080523-f1d5', N'MAI', N'0914326891', N'Ð?i h?c cntt', '2026-05-20 08:05:23.764', N'Ðã h?y', 100000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2022, N'ORD-20260520160723-f906', N'Nguy?n Minh', N'0366866688', N'Ð?i h?c cntt', '2026-05-20 16:07:23.162', N'Hoàn thành', 155000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2023, N'ORD-20260520160843-ede2', N'Hoàng Nam ', N'0914681725', N'Ð?i h?c ntt', '2026-05-20 16:08:43.760', N'Hoàn thành', 228000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2024, N'ORD-20260521072706-a6a0', N'Minh Ðang', N'0364566540', N'Ð?i h?c cntt', '2026-05-21 07:27:06.901', N'Ðã h?y', 215000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2025, N'ORD-20260521073342-711d', N'lam', N'0989768889', N'nam', '2026-05-21 07:33:42.112', N'Hoàn thành', 125000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2026, N'ORD-20260521082323-61f4', N'DO AN', N'0989344556', N'Ð?i h?c cntt', '2026-05-21 08:23:23.364', N'Hoàn thành', 72000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2027, N'ORD-20260521083724-6645', N'Duy', N'0911112112', N'Ð?i H?c CNTT', '2026-05-21 08:37:24.754', N'Hoàn thành', 205000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2028, N'ORD-20260521084002-0314', N'Hà', N'0366456789', N'Ð?i h?c cntt', '2026-05-21 08:40:02.315', N'Hoàn thành', 219998.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2029, N'ORD-20260521090116-4c53', N'Nhung Nguy?n', N'0345456678', N'Ð?i H?c CNTT', '2026-05-21 09:01:16.642', N'Hoàn thành', 255000.00, 2008, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2030, N'ORD-20260521094818-edf4', N'Vu', N'0935654455', N'Ð?i h?c cntt', '2026-05-21 09:48:18.413', N'Hoàn thành', 293000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2031, N'ORD-20260522093658-3e49', N'Nguy?n An', N'0334451452', N'B?c Ninh', '2026-05-22 09:36:58.621', N'Hoàn thành', 81000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2032, N'ORD-20260522093754-bd07', N'Nguy?n Minh', N'0964456123', N'Thái Nguyên', '2026-05-22 09:37:54.963', N'Hoàn thành', 469998.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2033, N'ORD-20260522094721-11c8', N'Hoàng Chi', N'0966898887', N'Ch? Bãi 2, Yên Phúc , Van Quan , L?ng Son', '2026-05-22 09:47:21.796', N'Hoàn thành', 375000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2034, N'ORD-20260522095046-75ec', N'Tri?u Huy', N'0234551212', N'Tri L? , L?ng Son', '2026-05-22 09:50:46.722', N'Hoàn thành', 337000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2035, N'ORD-20260522214249-7891', N'Nguy?n Hoàng', N'0398899123', N'Thái Nguyên', '2026-05-22 21:42:49.110', N'Hoàn thành', 288000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2036, N'ORD-20260523203008-5971', N'Chi Nguy?n', N'0891123789', N'Phú Bình , Thái Nguyên', '2026-05-23 20:30:08.553', N'Hoàn thành', 366000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2037, N'ORD-20260523210631-4869', N'Nhung Nguy?n', N'0912121122', N'Ð?i h?c cntt', '2026-05-23 21:06:31.391', N'Hoàn thành', 165000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2038, N'ORD-20260523211107-bf9d', N'Hiên L?c', N'0398892300', N'Tri L?, L?ng Son', '2026-05-23 21:11:07.972', N'Hoàn thành', 220000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2039, N'ORD-20260523212605-1487', N'Nam', N'0912567789', N'Ð?i h?c cntt', '2026-05-23 21:26:05.313', N'Hoàn thành', 265000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2040, N'ORD-20260523213029-f926', N'L?c Hi?n', N'0367456123', N'Thái Bình', '2026-05-23 21:30:29.984', N'Hoàn thành', 265000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2041, N'ORD-20260523213132-55bc', N'L?c Hu?ng', N'0392178890', N'B?c Ninh', '2026-05-23 21:31:32.124', N'Hoàn thành', 195000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2042, N'ORD-20260523220702-d152', N'Huy Nguy?n', N'0890988878', N'Thái Nguyên', '2026-05-23 22:07:02.925', N'Hoàn thành', 820000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2043, N'ORD-20260523220821-eb78', N'Nam', N'0912678321', N'Thái Bình', '2026-05-23 22:08:21.787', N'Hoàn thành', 401000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2044, N'ORD-20260523225037-8a54', N'Ðào Tuoi', N'0855132123', N'Ð?i T?', '2026-05-23 22:50:37.015', N'Hoàn thành', 229000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2045, N'ORD-20260523225113-1b8c', N'Tuoi', N'0989124989', N'CNTT', '2026-05-23 22:51:13.811', N'Hoàn thành', 304000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (2046, N'ORD-20260524223123-7c27', N'Huy', N'0989123358', N'Tri L?', '2026-05-24 22:31:23.186', N'Hoàn thành', 179000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3046, N'ORD-20260525094614-1694', N'Chi Hoàng', N'0964456656', N'Ð?i h?c thái nguyên', '2026-05-25 09:46:14.863', N'Hoàn thành', 507000.00, 2005, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3047, N'ORD-20260525183101-b041', N'Hoàng Ng?c Lan', N'0969897789', N'Ð?i h?c Thái Nguyên', '2026-05-25 18:31:01.987', N'Hoàn thành', 115000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3048, N'ORD-20260525183210-0690', N'Ðào Tuoi', N'0913345567', N'Ð?i T?, Thái Nguyên', '2026-05-25 18:32:10.360', N'Hoàn thành', 479000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3049, N'ORD-20260525215011-a5dc', N'Chi Chi', N'0387352189', N'Phu?ng Thanh Xuân, Hà N?i', '2026-05-25 21:50:11.107', N'Hoàn thành', 190000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3050, N'ORD-20260527161353-9c96', N'Tuoi', N'0956123789', N'Ð?i t? thái nguyên', '2026-05-27 16:13:53.879', N'Hoàn thành', 75000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3051, N'ORD-20260527221954-7f97', N'Mai', N'0914454678', N'Ð?i h?c Thái Nguyên', '2026-05-27 22:19:54.387', N'Hoàn thành', 218000.00, 1002, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3052, N'ORD-20260527222530-b9b4', N'Huy Tri?u', N'0989991899', N'Ð?i h?c gtvt', '2026-05-27 22:25:30.873', N'Hoàn thành', 115000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3053, N'ORD-20260527223545-91e2', N'Hoàng Son', N'0914567765', N'Liên H?i, L?ng Son', '2026-05-27 22:35:45.627', N'Hoàn thành', 162000.00, 2011, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3054, N'ORD-20260527225313-fb06', N'Quang', N'0814456459', N'Thái Nguyên', '2026-05-27 22:53:13.312', N'Hoàn thành', 55000.00, 2004, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3055, N'ORD-20260527230333-572a', N'Son Hoàng', N'0989342789', N'Qu? Võ, B?c Ninh', '2026-05-27 23:03:33.818', N'Hoàn thành', 175000.00, 2004, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3056, N'ORD-20260528173751-2863', N'Ðào Tuoi', N'0989431678', N'Ð?i T? Thái Nguyên', '2026-05-28 17:37:51.377', N'Hoàn thành', 145000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3057, N'ORD-20260528173829-2f2d', N'H?ng', N'0895568890', N'Ð?i h?c cntt', '2026-05-28 17:38:29.875', N'Hoàn thành', 140000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3058, N'ORD-20260528173942-5ddc', N'Son Hoàng', N'0912234456', N'Vân M?ng L?ng Son', '2026-05-28 17:39:42.853', N'Hoàn thành', 189000.00, 2011, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3059, N'ORD-20260528174037-15b7', N'Lan', N'0845135568', N'Qu?ng Ninh', '2026-05-28 17:40:37.074', N'Hoàn thành', 167000.00, 2011, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3060, N'ORD-20260528174259-422c', N'Th? Anh', N'0890123321', N'C?ng c2 cntt', '2026-05-28 17:42:59.223', N'Hoàn thành', 100000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3061, N'ORD-20260528174403-8090', N'd?i h?c', N'0945124214', N'Ð?i h?c cntt', '2026-05-28 17:44:03.014', N'Hoàn thành', 77000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3062, N'ORD-20260528174440-1041', N'Th? Anh', N'0989431789', N'qu?ng ninh vi?t nam', '2026-05-28 17:44:40.509', N'Hoàn thành', 260000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3063, N'ORD-20260528174919-2779', N'Minh', N'0889456899', N'd?i h?c khxh và nv', '2026-05-28 17:49:19.416', N'Hoàn thành', 107000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3064, N'ORD-20260528174950-917a', N'nam', N'0845678453', N'Ð?i h?c xây d?ng', '2026-05-28 17:49:50.020', N'Hoàn thành', 162000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3065, N'ORD-20260528175022-6db3', N'L?c', N'0943125679', N'Ð?i h?c cntt', '2026-05-28 17:50:22.816', N'Hoàn thành', 90000.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3066, N'ORD-20260528175209-702c', N'lochien', N'0889989908', N'd?i h?c cntt', '2026-05-28 17:52:09.167', N'Hoàn thành', 60000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3067, N'ORD-20260528175246-3048', N'nhung nguy?n', N'0378878890', N'd?i h?c cntt', '2026-05-28 17:52:46.852', N'Hoàn thành', 200000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3068, N'ORD-20260528175320-93c9', N'Th? Anh', N'0989489123', N'c2 c?ng ph? cntt', '2026-05-28 17:53:20.820', N'Hoàn thành', 90000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3069, N'ORD-20260528175405-b949', N'th? anh', N'0352189687', N'thành ph? h? long qu?ng ninh', '2026-05-28 17:54:05.074', N'Hoàn thành', 130000.00, 2012, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3070, N'ORD-20260528175652-141c', N'minh anh', N'0941123456', N'yên phúc van quan l?ng son', '2026-05-28 17:56:52.866', N'Hoàn thành', 97000.00, 2013, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3071, N'ORD-20260528182057-df5f', N'Nguy?n An', N'0966454544', N'd?i h?c cntt', '2026-05-28 18:20:57.013', N'Hoàn thành', 283000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3072, N'ORD-20260528182140-8b7a', N'Tr?n Son', N'0355567657', N'Ð?i h?c cntt', '2026-05-28 18:21:40.939', N'Hoàn thành', 663999.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3073, N'ORD-20260528182223-dd60', N'Hoàng Ng?c', N'0367836787', N'd?i h?c cntt', '2026-05-28 18:22:23.580', N'Hoàn thành', 100000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3074, N'ORD-20260528182258-4152', N'Hoàng Lan', N'0376678786', N'd?i h?c cntt', '2026-05-28 18:22:58.362', N'Hoàn thành', 260000.00, 2003, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3075, N'ORD-20260528182525-f4b1', N'Hoàng B?ng', N'0945545342', N'xã quang châu b?c giang', '2026-05-28 18:25:25.514', N'Hoàn thành', 155000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3076, N'ORD-20260528182603-c626', N'b?ng hoàng', N'0945543343', N'xã  quang châu , viejt yên b?c giang', '2026-05-28 18:26:03.187', N'Hoàn thành', 81000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3077, N'ORD-20260528182641-a3f3', N'Hoàng Duy', N'0977656688', N'd?i h?c cntt', '2026-05-28 18:26:41.541', N'Hoàn thành', 182000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3078, N'ORD-20260528182723-9db2', N'Chuong L?c', N'0862566654', N'd?i h?c cntt', '2026-05-28 18:27:23.740', N'Hoàn thành', 265000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3079, N'ORD-20260528184549-1dc1', N'L?c Hiên', N'0398892300', N'luong nang van quan l?ng son', '2026-05-28 18:45:49.773', N'Hoàn thành', 354999.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3080, N'ORD-20260528184628-8de9', N'Bích Hiên', N'0398892300', N'd?i h?c cntt', '2026-05-28 18:46:28.007', N'Hoàn thành', 115000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3081, N'ORD-20260528184708-af95', N'L?c Hi?n', N'0357128151', N'ki?n xuong thái bình', '2026-05-28 18:47:08.391', N'Hoàn thành', 65000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3082, N'ORD-20260528184742-ac3e', N'L?c Hu?ng', N'0932222344', N'luong nang l?ng son', '2026-05-28 18:47:42.372', N'Hoàn thành', 130000.00, 2010, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3083, N'ORD-20260528184953-c773', N'L?c Thuong', N'0989688786', N'd?i h?c cntt', '2026-05-28 18:49:53.866', N'Hoàn thành', 102000.00, 2015, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3084, N'ORD-20260528185046-abac', N'Bách Hoàng', N'0123456789', N'd?i h?c xây d?ng', '2026-05-28 18:50:46.436', N'Hoàn thành', 569999.00, 2015, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3085, N'ORD-20260528185125-8720', N'B?o Hân', N'0912468999', N'qu? võ b?c ninh', '2026-05-28 18:51:25.183', N'Hoàn thành', 165000.00, 2015, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3086, N'ORD-20260528191331-f193', N'Duy', N'0904024561', N'phú bình thái nguyên', '2026-05-28 19:13:31.322', N'Hoàn thành', 294999.00, 2016, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3087, N'ORD-20260528191410-d5ee', N'Long', N'0989888111', N'd?i h?c cntt', '2026-05-28 19:14:10.240', N'Hoàn thành', 112000.00, 2016, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3088, N'ORD-20260528191445-c604', N'QUÂN', N'0123456789', N'Ð?i h?c cntt', '2026-05-28 19:14:45.093', N'Hoàn thành', 124000.00, 2016, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3089, N'ORD-20260528191525-c8b6', N'Van Ðình', N'0343323781', N'd?i h?c cntt', '2026-05-28 19:15:25.151', N'Hoàn thành', 75000.00, 2016, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3090, N'ORD-20260528191606-05dd', N'quang huy', N'0365565456', N'd?i h?c cntt', '2026-05-28 19:16:06.520', N'Hoàn thành', 60000.00, 2016, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3091, N'ORD-20260528191702-732c', N'b?ng', N'0123432145', N'd?i h?c cntt', '2026-05-28 19:17:02.684', N'Hoàn thành', 213000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3092, N'ORD-20260528191754-89cc', N'loc thanh', N'0567898753', N'van quan lang son', '2026-05-28 19:17:54.186', N'Hoàn thành', 90000.00, 2014, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3093, N'ORD-20260528192338-ed0d', N'huy', N'0988888888', N'd?i h?c gtvt', '2026-05-28 19:23:38.794', N'Hoàn thành', 64000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3094, N'ORD-20260528192559-bed6', N'dông', N'0989898911', N'd?i h?c ngo?i ng?', '2026-05-28 19:25:59.427', N'Hoàn thành', 145000.00, 2007, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3095, N'ORD-20260529175237-4408', N'Hoàng Th? Chi', N'0366852169', N'Thôn Ch? Bãi , Xã Yên Phúc , Huy?n Van Quan, T?nh L?ng Son', '2026-05-29 17:52:37.928', N'Hoàn thành', 585999.00, 2006, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3096, N'ORD-20260530162649-cb38', N'Tr?n Van Minh', N'0980088189', N'd?i h?c cntt', '2026-05-30 16:26:49.612', N'Hoàn thành', 272000.00, 2017, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3097, N'ORD-20260530162758-4509', N'Hoa', N'0914457890', N'd?i h?c cntt', '2026-05-30 16:27:58.180', N'Hoàn thành', 270000.00, 2017, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3098, N'ORD-20260531190022-ce88', N'Hnê·', N'0989112456', N'd?i h?c cntt', '2026-05-31 19:00:22.365', N'Hoàn thành', 1233998.00, 2017, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3099, N'ORD-20260531190704-23ff', N'Hoàng Thanh H?i', N'0944555555', N'Ð?i h?c cntt', '2026-05-31 19:07:04.372', N'Hoàn thành', 247000.00, 2018, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3100, N'ORD-20260531191729-de47', N'Hoàng Th? Phuong', N'0387300500', N'Ð?i h?c cntt', '2026-05-31 19:17:29.647', N'Ðã h?y', 320000.00, 2019, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3101, N'ORD-20260531223342-ae3c', N'Phuong', N'0999999999', N'd?i h?c cntt tt thái nguyên', '2026-05-31 22:33:42.983', N'Hoàn thành', 96000.00, 2019, 25000.00);
INSERT INTO [Orders] ([OrderId], [OrderCode], [ReceiveName], [ReceivePhone], [ReceiveAddress], [OrderDate], [OrderStatus], [TotalAmount], [UserId], [ShipmentPrice]) VALUES (3102, N'ORD-20260531223555-e1a7', N'Hoàng Phuong', N'0999999999', N'd?i h?c cntt tt thái nguyên', '2026-05-31 22:35:55.479', N'Ðã h?y', 150000.00, 2019, 25000.00);
SET IDENTITY_INSERT [Orders] OFF;

-- Data for table OrderItems
SET IDENTITY_INSERT [OrderItems] ON;
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1, 2, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2, 2, 5, 10000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3, 3, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (4, 3, 3, 30000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1002, 1002, 3, 30000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1003, 1002, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1004, 1002, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1005, 1003, 3, 30000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1006, 1003, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1007, 1003, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1008, 1004, 7, 45000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1009, 1004, 1003, 35000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1010, 1004, 1006, 33000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1011, 1005, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1012, 1005, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1013, 1005, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1014, 1006, 1005, 100000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1015, 1006, 1004, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1016, 1006, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1017, 1006, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1018, 1006, 5, 10000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1019, 1007, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1020, 1007, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1021, 1008, 1009, 27999.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1022, 1008, 1011, 84998.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1023, 1008, 1006, 33000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1024, 1009, 3, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1025, 1009, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1026, 1009, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1027, 1010, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1028, 1011, 1011, 84998.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1029, 1011, 1005, 100000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1030, 1011, 5, 10000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1031, 1011, 1012, 50000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1032, 1012, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1033, 1012, 5, 10000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1034, 1012, 1010, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1035, 1013, 3, 30000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1036, 1013, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1037, 1013, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1038, 1013, 1011, 84998.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1039, 1014, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1040, 1014, 1006, 33000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1041, 1014, 1005, 100000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1042, 1014, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1043, 1015, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1044, 1015, 1011, 84998.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1045, 1015, 1013, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1046, 1016, 1013, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1047, 1016, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1048, 1016, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1049, 1016, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1050, 1017, 1015, 8000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1051, 1017, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1052, 1017, 1016, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1053, 1018, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1054, 1018, 2, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1055, 1018, 7, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1056, 1019, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1057, 1019, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1058, 1019, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1059, 1019, 6, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1060, 1019, 1022, 25000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1061, 1020, 1009, 27999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1062, 1020, 3, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1063, 1020, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1064, 1020, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1065, 1020, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1066, 1021, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1067, 1021, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1068, 1021, 1019, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1069, 1021, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1070, 1021, 1016, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1071, 1021, 1013, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1072, 1022, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1073, 1022, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1074, 1022, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1075, 1022, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1076, 1022, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1077, 1022, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1078, 1022, 1019, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1079, 1022, 3, 35000.00, 3);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (1080, 1022, 5, 10000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2061, 2020, 5, 10000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2062, 2020, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2063, 2020, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2064, 2021, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2065, 2021, 1024, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2066, 2021, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2067, 2022, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2068, 2022, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2069, 2022, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2070, 2023, 4, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2071, 2023, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2072, 2023, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2073, 2023, 1009, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2074, 2023, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2075, 2024, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2076, 2024, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2077, 2024, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2078, 2025, 1019, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2079, 2025, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2080, 2026, 1024, 12000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2081, 2026, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2082, 2026, 5, 10000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2083, 2027, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2084, 2027, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2085, 2027, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2086, 2028, 1013, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2087, 2028, 1010, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2088, 2028, 1011, 84998.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2089, 2029, 1025, 115000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2090, 2030, 1009, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2091, 2030, 3, 35000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2092, 2030, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2093, 2030, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2094, 2030, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2095, 2031, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2096, 2031, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2097, 2031, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2098, 2032, 1025, 115000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2099, 2032, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2100, 2032, 1011, 84998.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2101, 2032, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2102, 2032, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2103, 2032, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2104, 2033, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2105, 2033, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2106, 2033, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2107, 2033, 1010, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2108, 2033, 1009, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2109, 2033, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2110, 2033, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2111, 2034, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2112, 2034, 1024, 12000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2113, 2034, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2114, 2034, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2115, 2034, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2116, 2034, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2117, 2034, 1016, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2118, 2035, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2119, 2035, 1025, 115000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2120, 2035, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2121, 2035, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2122, 2035, 1024, 12000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2123, 2035, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2124, 2036, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2125, 2036, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2126, 2036, 1024, 12000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2127, 2036, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2128, 2036, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2129, 2036, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2130, 2036, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2131, 2036, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2132, 2037, 1028, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2133, 2037, 1029, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2134, 2037, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2135, 2038, 1033, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2136, 2038, 1032, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2137, 2038, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2138, 2038, 1030, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2139, 2038, 1026, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2140, 2039, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2141, 2039, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2142, 2039, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2143, 2039, 1032, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2144, 2039, 1030, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2145, 2039, 1033, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2146, 2040, 1005, 85000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2147, 2040, 2, 35000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2148, 2041, 1003, 35000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2149, 2041, 4, 15000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2150, 2041, 7, 35000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2151, 2042, 1038, 155000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2152, 2042, 1037, 59000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2153, 2042, 1036, 40000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2154, 2042, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2155, 2042, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2156, 2042, 1026, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2157, 2042, 1025, 115000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2158, 2043, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2159, 2043, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2160, 2043, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2161, 2043, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2162, 2043, 1029, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2163, 2043, 1025, 115000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2164, 2044, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2165, 2044, 1036, 40000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2166, 2044, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2167, 2045, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2168, 2045, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2169, 2045, 1038, 155000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2170, 2046, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2171, 2046, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2172, 2046, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (2173, 2046, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3170, 3046, 1033, 35000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3171, 3046, 1032, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3172, 3046, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3173, 3046, 1030, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3174, 3046, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3175, 3046, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3176, 3046, 1026, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3177, 3046, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3178, 3046, 1028, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3179, 3046, 1029, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3180, 3046, 1023, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3181, 3047, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3182, 3047, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3183, 3047, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3184, 3048, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3185, 3048, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3186, 3048, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3187, 3048, 1015, 8000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3188, 3048, 1016, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3189, 3048, 1013, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3190, 3048, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3191, 3048, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3192, 3048, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3193, 3048, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3194, 3048, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3195, 3049, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3196, 3049, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3197, 3049, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3198, 3050, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3199, 3050, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3200, 3051, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3201, 3051, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3202, 3051, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3203, 3051, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3204, 3051, 1013, 52000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3205, 3052, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3206, 3052, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3207, 3052, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3208, 3053, 1013, 52000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3209, 3053, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3210, 3053, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3211, 3053, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3212, 3054, 4, 15000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3213, 3055, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3214, 3055, 1004, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3215, 3055, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3216, 3056, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3217, 3056, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3218, 3057, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3219, 3057, 1011, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3220, 3057, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3221, 3058, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3222, 3058, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3223, 3058, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3224, 3059, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3225, 3059, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3226, 3059, 1026, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3227, 3060, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3228, 3060, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3229, 3061, 1013, 52000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3230, 3062, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3231, 3062, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3232, 3062, 1025, 115000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3233, 3062, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3234, 3063, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3235, 3063, 1019, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3236, 3063, 1024, 12000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3237, 3064, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3238, 3064, 1013, 52000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3239, 3065, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3240, 3065, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3241, 3066, 2, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3242, 3067, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3243, 3067, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3244, 3067, 1004, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3245, 3067, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3246, 3068, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3247, 3068, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3248, 3069, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3249, 3069, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3250, 3070, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3251, 3070, 1028, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3252, 3071, 1044, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3253, 3071, 1043, 48000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3254, 3071, 1041, 145000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3255, 3072, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3256, 3072, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3257, 3072, 1038, 155000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3258, 3072, 1040, 399999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3259, 3073, 1011, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3260, 3073, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3261, 3074, 1042, 90000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3262, 3074, 1041, 145000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3263, 3075, 1042, 90000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3264, 3075, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3265, 3076, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3266, 3076, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3267, 3076, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3268, 3077, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3269, 3077, 1013, 52000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3270, 3078, 1039, 175000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3271, 3078, 1030, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3272, 3078, 1034, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3273, 3079, 1047, 99999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3274, 3079, 1046, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3275, 3079, 1039, 175000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3276, 3080, 1042, 90000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3277, 3081, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3278, 3081, 2, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3279, 3082, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3280, 3082, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3281, 3083, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3282, 3083, 3, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3283, 3084, 1041, 145000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3284, 3084, 1040, 399999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3285, 3085, 1014, 105000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3286, 3085, 1009, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3287, 3086, 1047, 99999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3288, 3086, 1042, 90000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3289, 3086, 1045, 80000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3290, 3087, 1022, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3291, 3087, 1017, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3292, 3087, 1024, 12000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3293, 3088, 1037, 59000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3294, 3088, 1036, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3295, 3089, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3296, 3089, 1030, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3297, 3090, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3298, 3091, 1048, 78000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3299, 3091, 1049, 110000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3300, 3092, 1004, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3301, 3092, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3302, 3093, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3303, 3093, 5, 6000.00, 4);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3304, 3094, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3305, 3094, 1045, 80000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3306, 3095, 1050, 79000.00, 2);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3307, 3095, 1047, 99999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3308, 3095, 1049, 110000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3309, 3095, 1043, 48000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3310, 3095, 1041, 145000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3311, 3096, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3312, 3096, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3313, 3096, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3314, 3096, 1050, 79000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3315, 3096, 1048, 78000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3316, 3097, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3317, 3097, 1035, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3318, 3097, 1038, 155000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3319, 3098, 7, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3320, 3098, 1012, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3321, 3098, 1008, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3322, 3098, 1007, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3323, 3098, 1050, 79000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3324, 3098, 1047, 99999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3325, 3098, 1042, 90000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3326, 3098, 1041, 145000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3327, 3098, 1040, 399999.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3328, 3098, 1046, 55000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3329, 3098, 1049, 110000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3330, 3098, 1044, 65000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3331, 3099, 1005, 85000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3332, 3099, 1004, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3333, 3099, 1003, 35000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3334, 3099, 1027, 42000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3335, 3099, 1028, 30000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3336, 3100, 1039, 175000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3337, 3100, 1032, 45000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3338, 3100, 1031, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3339, 3100, 1028, 50000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3340, 3101, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3341, 3101, 6, 40000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3342, 3101, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3343, 3102, 4, 15000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3344, 3102, 5, 6000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3345, 3102, 1006, 25000.00, 1);
INSERT INTO [OrderItems] ([OrderItemId], [OrderId], [PackageId], [OrderPrice], [OrderQuantity]) VALUES (3346, 3102, 1050, 79000.00, 1);
SET IDENTITY_INSERT [OrderItems] OFF;

-- Data for table Payments
SET IDENTITY_INSERT [Payments] ON;
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1, N'COD', 0.00, N'Pending', 1, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2, N'COD', 40000.00, N'Pending', 2, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3, N'COD', 90000.00, N'Pending', 3, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1002, N'VNPay', 185000.00, N'Pending', 1002, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1003, N'VNPay', 185000.00, N'Ðã thanh toán', 1003, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1004, N'VNPay', 364000.00, N'Ðã thanh toán', 1004, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1005, N'COD', 155000.00, N'Pending', 1005, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1006, N'COD', 235000.00, N'Pending', 1006, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1007, N'VNPay', 85000.00, N'Ðã thanh toán', 1007, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1008, N'COD', 344993.00, N'Pending', 1008, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1009, N'COD', 110000.00, N'Pending', 1009, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1010, N'COD', 50000.00, N'Pending', 1010, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1011, N'COD', 524996.00, N'Pending', 1011, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1012, N'COD', 125000.00, N'Pending', 1012, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1013, N'COD', 269998.00, N'Pending', 1013, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1014, N'VNPay', 243000.00, N'Ðã thanh toán', 1014, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1015, N'COD', 279998.00, N'Pending', 1015, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1016, N'VNPay', 190000.00, N'Ðã thanh toán', 1016, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1017, N'COD', 184000.00, N'Pending', 1017, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1018, N'COD', 125000.00, N'Pending', 1018, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1019, N'COD', 250000.00, N'Ðã thanh toán', 1019, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1020, N'VNPay', 245999.00, N'Ðã thanh toán', 1020, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1021, N'VNPay', 350000.00, N'Th?t b?i', 1021, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (1022, N'VNPay', 335000.00, N'Th?t b?i', 1022, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2020, N'VNPay', 100000.00, N'Ðã thanh toán', 2020, '2026-05-20 01:04:28.681', '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2021, N'VNPay', 100000.00, N'Th?t b?i', 2021, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2022, N'COD', 155000.00, N'Ðã thanh toán', 2022, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2023, N'COD', 228000.00, N'Ðã thanh toán', 2023, NULL, '0001-01-01 00:00:00.000');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2024, N'VNPay', 215000.00, N'Cancelled', 2024, '2026-05-21 07:33:02.951', '2026-05-21 07:27:07.789');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2025, N'VNPay', 125000.00, N'Paid', 2025, '2026-05-21 07:51:48.838', '2026-05-21 07:33:42.369');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2026, N'NCB', 72000.00, N'Paid', 2026, '2026-05-21 08:25:45.710', '2026-05-21 08:23:24.448');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2027, N'NCB', 205000.00, N'Paid', 2027, '2026-05-21 08:41:23.000', '2026-05-21 08:37:26.264');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2028, N'COD', 219998.00, N'Paid', 2028, '2026-05-21 08:41:15.108', '2026-05-21 08:40:02.799');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2029, N'COD', 255000.00, N'Paid', 2029, '2026-05-21 09:01:44.674', '2026-05-21 09:01:17.016');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2030, N'NCB', 293000.00, N'Paid', 2030, '2026-05-21 10:00:52.278', '2026-05-21 09:48:19.337');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2031, N'COD', 81000.00, N'Paid', 2031, '2026-05-22 09:39:03.151', '2026-05-22 09:36:58.997');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2032, N'COD', 469998.00, N'Paid', 2032, '2026-05-22 09:38:41.776', '2026-05-22 09:37:56.143');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2033, N'COD', 375000.00, N'Paid', 2033, '2026-05-22 09:49:11.030', '2026-05-22 09:47:22.716');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2034, N'COD', 337000.00, N'Paid', 2034, '2026-05-22 09:51:25.386', '2026-05-22 09:50:47.573');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2035, N'COD', 288000.00, N'Paid', 2035, '2026-05-22 21:43:26.332', '2026-05-22 21:42:52.016');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2036, N'COD', 366000.00, N'Paid', 2036, '2026-05-23 21:09:08.439', '2026-05-23 20:30:10.301');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2037, N'COD', 165000.00, N'Paid', 2037, '2026-05-23 21:09:02.494', '2026-05-23 21:06:32.445');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2038, N'NCB', 220000.00, N'Paid', 2038, '2026-05-23 21:33:02.819', '2026-05-23 21:11:08.620');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2039, N'COD', 265000.00, N'Paid', 2039, '2026-05-23 21:33:11.005', '2026-05-23 21:26:06.821');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2040, N'COD', 265000.00, N'Paid', 2040, '2026-05-23 21:32:56.454', '2026-05-23 21:30:32.052');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2041, N'COD', 195000.00, N'Paid', 2041, '2026-05-23 21:32:50.704', '2026-05-23 21:31:33.706');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2042, N'COD', 820000.00, N'Paid', 2042, '2026-05-23 22:09:08.639', '2026-05-23 22:07:05.573');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2043, N'COD', 401000.00, N'Paid', 2043, '2026-05-23 22:09:02.804', '2026-05-23 22:08:22.800');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2044, N'COD', 229000.00, N'Paid', 2044, '2026-05-23 22:52:32.028', '2026-05-23 22:50:38.418');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2045, N'COD', 304000.00, N'Paid', 2045, '2026-05-23 22:52:26.202', '2026-05-23 22:51:14.870');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (2046, N'COD', 179000.00, N'Paid', 2046, '2026-05-24 22:32:12.854', '2026-05-24 22:31:25.289');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3046, N'COD', 507000.00, N'Paid', 3046, '2026-05-25 09:46:48.394', '2026-05-25 09:46:16.654');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3047, N'COD', 115000.00, N'Paid', 3047, '2026-05-25 18:32:56.252', '2026-05-25 18:31:04.093');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3048, N'COD', 479000.00, N'Paid', 3048, '2026-05-25 18:32:51.474', '2026-05-25 18:32:11.617');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3049, N'COD', 190000.00, N'Paid', 3049, '2026-05-25 21:51:14.354', '2026-05-25 21:50:13.908');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3050, N'COD', 75000.00, N'Paid', 3050, '2026-05-27 17:01:13.329', '2026-05-27 16:13:56.259');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3051, N'COD', 218000.00, N'Paid', 3051, '2026-05-27 22:21:01.799', '2026-05-27 22:19:55.727');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3052, N'NCB', 115000.00, N'Paid', 3052, '2026-05-29 16:50:25.851', '2026-05-27 22:25:31.749');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3053, N'COD', 162000.00, N'Paid', 3053, '2026-05-27 23:08:05.900', '2026-05-27 22:35:46.524');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3054, N'COD', 55000.00, N'Paid', 3054, '2026-05-27 23:07:59.729', '2026-05-27 22:53:13.762');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3055, N'COD', 175000.00, N'Paid', 3055, '2026-05-27 23:07:40.277', '2026-05-27 23:03:35.131');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3056, N'COD', 145000.00, N'Paid', 3056, '2026-05-28 17:47:15.826', '2026-05-28 17:37:52.853');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3057, N'COD', 140000.00, N'Paid', 3057, '2026-05-28 17:47:05.896', '2026-05-28 17:38:31.878');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3058, N'COD', 189000.00, N'Paid', 3058, '2026-05-28 17:47:00.892', '2026-05-28 17:39:43.782');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3059, N'COD', 167000.00, N'Paid', 3059, '2026-05-28 17:46:56.160', '2026-05-28 17:40:41.035');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3060, N'COD', 100000.00, N'Paid', 3060, '2026-05-28 17:59:22.415', '2026-05-28 17:42:59.608');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3061, N'COD', 77000.00, N'Paid', 3061, '2026-05-28 17:46:51.196', '2026-05-28 17:44:03.228');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3062, N'COD', 260000.00, N'Paid', 3062, '2026-05-28 17:46:43.779', '2026-05-28 17:44:41.214');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3063, N'COD', 107000.00, N'Paid', 3063, '2026-05-28 17:59:15.284', '2026-05-28 17:49:19.875');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3064, N'COD', 162000.00, N'Paid', 3064, '2026-05-28 17:59:11.081', '2026-05-28 17:49:50.475');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3065, N'COD', 90000.00, N'Paid', 3065, '2026-05-28 17:59:06.650', '2026-05-28 17:50:23.072');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3066, N'COD', 60000.00, N'Paid', 3066, '2026-05-28 17:58:56.019', '2026-05-28 17:52:09.401');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3067, N'COD', 200000.00, N'Paid', 3067, '2026-05-28 17:58:49.610', '2026-05-28 17:52:47.417');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3068, N'COD', 90000.00, N'Paid', 3068, '2026-05-28 17:58:45.573', '2026-05-28 17:53:21.050');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3069, N'COD', 130000.00, N'Paid', 3069, '2026-05-28 17:58:41.439', '2026-05-28 17:54:05.588');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3070, N'COD', 97000.00, N'Paid', 3070, '2026-05-28 17:58:37.456', '2026-05-28 17:56:53.154');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3071, N'COD', 283000.00, N'Paid', 3071, '2026-05-28 18:28:38.616', '2026-05-28 18:20:57.777');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3072, N'COD', 663999.00, N'Paid', 3072, '2026-05-28 18:28:33.641', '2026-05-28 18:21:41.808');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3073, N'COD', 100000.00, N'Paid', 3073, '2026-05-28 18:28:28.627', '2026-05-28 18:22:23.799');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3074, N'COD', 260000.00, N'Paid', 3074, '2026-05-28 18:28:24.120', '2026-05-28 18:22:58.724');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3075, N'COD', 155000.00, N'Paid', 3075, '2026-05-28 18:28:19.891', '2026-05-28 18:25:25.896');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3076, N'COD', 81000.00, N'Paid', 3076, '2026-05-28 18:28:15.173', '2026-05-28 18:26:03.617');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3077, N'COD', 182000.00, N'Paid', 3077, '2026-05-28 18:28:10.855', '2026-05-28 18:26:41.974');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3078, N'COD', 265000.00, N'Paid', 3078, '2026-05-28 18:28:05.900', '2026-05-28 18:27:24.222');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3079, N'COD', 354999.00, N'Paid', 3079, '2026-05-28 18:52:15.965', '2026-05-28 18:45:50.532');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3080, N'COD', 115000.00, N'Paid', 3080, '2026-05-28 18:52:10.479', '2026-05-28 18:46:28.283');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3081, N'COD', 65000.00, N'Paid', 3081, '2026-05-28 18:52:05.228', '2026-05-28 18:47:08.695');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3082, N'COD', 130000.00, N'Paid', 3082, '2026-05-28 18:52:00.961', '2026-05-28 18:47:42.744');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3083, N'COD', 102000.00, N'Paid', 3083, '2026-05-28 18:51:57.083', '2026-05-28 18:49:54.186');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3084, N'COD', 569999.00, N'Paid', 3084, '2026-05-28 18:51:52.784', '2026-05-28 18:50:46.842');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3085, N'COD', 165000.00, N'Paid', 3085, '2026-05-28 18:51:48.998', '2026-05-28 18:51:25.649');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3086, N'COD', 294999.00, N'Paid', 3086, '2026-05-28 19:18:58.797', '2026-05-28 19:13:32.202');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3087, N'COD', 112000.00, N'Paid', 3087, '2026-05-28 19:18:54.522', '2026-05-28 19:14:10.530');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3088, N'COD', 124000.00, N'Paid', 3088, '2026-05-28 19:18:48.444', '2026-05-28 19:14:45.457');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3089, N'COD', 75000.00, N'Paid', 3089, '2026-05-28 19:18:43.441', '2026-05-28 19:15:25.388');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3090, N'COD', 60000.00, N'Paid', 3090, '2026-05-28 19:18:39.355', '2026-05-28 19:16:06.636');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3091, N'COD', 213000.00, N'Paid', 3091, '2026-05-28 19:18:35.199', '2026-05-28 19:17:03.254');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3092, N'COD', 90000.00, N'Paid', 3092, '2026-05-28 19:18:29.514', '2026-05-28 19:17:54.366');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3093, N'COD', 64000.00, N'Paid', 3093, '2026-05-28 19:26:34.766', '2026-05-28 19:23:39.041');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3094, N'COD', 145000.00, N'Paid', 3094, '2026-05-28 19:26:30.490', '2026-05-28 19:25:59.850');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3095, N'COD', 585999.00, N'Paid', 3095, '2026-05-29 17:53:36.461', '2026-05-29 17:52:38.672');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3096, N'COD', 272000.00, N'Paid', 3096, '2026-05-30 16:28:37.412', '2026-05-30 16:26:52.442');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3097, N'COD', 270000.00, N'Paid', 3097, '2026-05-30 16:28:32.409', '2026-05-30 16:28:02.591');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3098, N'COD', 1233998.00, N'Paid', 3098, '2026-05-31 19:00:51.002', '2026-05-31 19:00:26.368');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3099, N'COD', 247000.00, N'Paid', 3099, '2026-05-31 21:59:15.681', '2026-05-31 19:07:05.065');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3100, N'NCB', 320000.00, N'Paid', 3100, '2026-05-31 19:19:21.820', '2026-05-31 19:17:30.288');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3101, N'NCB', 96000.00, N'Paid', 3101, '2026-05-31 22:42:59.880', '2026-05-31 22:33:43.430');
INSERT INTO [Payments] ([PaymentId], [PaymentMethod], [Amount], [PaymentStatus], [OrderId], [UpdatedAt], [CreatedAt]) VALUES (3102, N'VNPay', 150000.00, N'Cancelled', 3102, '2026-05-31 22:42:21.278', '2026-05-31 22:35:56.218');
SET IDENTITY_INSERT [Payments] OFF;

-- Data for table PaymentTransactions
SET IDENTITY_INSERT [PaymentTransactions] ON;
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1, 2026, NULL, N'15549093', N'NCB', N'00', N'Success', '2026-05-21 08:24:35.137');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (2, 2027, NULL, N'15549115', N'NCB', N'00', N'Success', '2026-05-21 08:39:11.657');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (3, 2028, NULL, NULL, NULL, NULL, N'Pending', '2026-05-21 08:40:02.908');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (4, 2029, NULL, NULL, NULL, NULL, N'Pending', '2026-05-21 09:01:17.131');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (5, 2030, N'20301779331699', N'15549229', N'NCB', N'00', N'Success', '2026-05-21 09:49:46.130');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (6, 2031, NULL, NULL, NULL, NULL, N'Pending', '2026-05-22 09:36:59.402');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (7, 2032, NULL, NULL, NULL, NULL, N'Pending', '2026-05-22 09:37:56.239');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (8, 2031, NULL, NULL, NULL, NULL, N'Success', '2026-05-22 09:38:58.910');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (9, 2033, NULL, NULL, NULL, NULL, N'Pending', '2026-05-22 09:47:22.899');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (10, 2034, NULL, NULL, NULL, NULL, N'Pending', '2026-05-22 09:50:47.670');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (11, 2035, NULL, NULL, NULL, NULL, N'Pending', '2026-05-22 21:42:52.901');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (12, 2036, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 20:30:10.697');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (13, 2037, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 21:06:32.804');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (14, 2038, N'20381779545468', N'15552904', N'NCB', N'00', N'Success', '2026-05-23 21:12:32.792');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (15, 2039, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 21:26:07.147');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (16, 2040, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 21:30:32.858');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (17, 2041, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 21:31:33.936');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (18, 2039, NULL, NULL, NULL, NULL, N'Success', '2026-05-23 21:33:07.874');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (19, 2042, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 22:07:05.917');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (20, 2043, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 22:08:22.888');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (21, 2044, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 22:50:39.290');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (22, 2045, NULL, NULL, NULL, NULL, N'Pending', '2026-05-23 22:51:15.081');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (23, 2046, NULL, NULL, NULL, NULL, N'Pending', '2026-05-24 22:31:25.775');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1023, 3046, NULL, NULL, NULL, NULL, N'Pending', '2026-05-25 09:46:17.027');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1024, 3047, NULL, NULL, NULL, NULL, N'Pending', '2026-05-25 18:31:04.544');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1025, 3048, NULL, NULL, NULL, NULL, N'Pending', '2026-05-25 18:32:11.695');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1026, 3049, NULL, NULL, NULL, NULL, N'Pending', '2026-05-25 21:50:14.491');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1027, 3050, NULL, NULL, NULL, NULL, N'Pending', '2026-05-27 16:13:56.765');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1028, 3051, NULL, NULL, NULL, NULL, N'Pending', '2026-05-27 22:19:56.207');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1029, 3052, N'30521779895531', N'15558846', N'NCB', N'00', N'Success', '2026-05-27 22:27:37.318');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1030, 3053, NULL, NULL, NULL, NULL, N'Pending', '2026-05-27 22:35:46.750');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1031, 3054, NULL, NULL, NULL, NULL, N'Pending', '2026-05-27 22:53:13.968');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1032, 3055, NULL, NULL, NULL, NULL, N'Pending', '2026-05-27 23:03:35.413');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1033, 3055, NULL, NULL, NULL, NULL, N'Success', '2026-05-27 23:07:37.124');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1034, 3056, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:37:53.476');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1035, 3057, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:38:33.364');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1036, 3058, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:39:44.034');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1037, 3059, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:40:41.144');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1038, 3060, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:42:59.808');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1039, 3061, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:44:03.332');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1040, 3062, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:44:41.308');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1041, 3061, NULL, NULL, NULL, NULL, N'Success', '2026-05-28 17:46:48.205');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1042, 3063, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:49:20.009');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1043, 3064, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:49:50.687');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1044, 3065, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:50:23.191');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1045, 3066, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:52:09.509');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1046, 3067, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:52:47.511');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1047, 3068, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:53:21.142');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1048, 3069, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:54:05.705');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1049, 3070, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 17:56:53.261');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1050, 3071, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:20:57.982');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1051, 3072, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:21:41.910');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1052, 3073, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:22:23.897');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1053, 3074, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:22:58.821');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1054, 3075, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:25:26.013');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1055, 3076, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:26:03.745');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1056, 3077, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:26:42.072');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1057, 3078, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:27:24.360');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1058, 3079, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:45:50.687');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1059, 3080, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:46:28.353');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1060, 3081, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:47:08.791');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1061, 3082, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:47:42.885');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1062, 3083, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:49:54.297');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1063, 3084, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:50:46.927');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1064, 3085, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 18:51:25.721');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1065, 3086, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:13:32.486');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1066, 3087, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:14:10.621');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1067, 3088, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:14:45.583');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1068, 3089, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:15:25.479');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1069, 3090, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:16:06.747');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1070, 3091, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:17:03.362');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1071, 3092, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:17:54.446');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1072, 3093, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:23:39.226');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1073, 3094, NULL, NULL, NULL, NULL, N'Pending', '2026-05-28 19:26:00.039');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1074, 3052, N'30521779895531', N'15558846', N'NCB', N'00', N'Success', '2026-05-29 16:50:25.551');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1075, 3095, NULL, NULL, NULL, NULL, N'Pending', '2026-05-29 17:52:39.199');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1076, 3096, NULL, NULL, NULL, NULL, N'Pending', '2026-05-30 16:26:53.267');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1077, 3097, NULL, NULL, NULL, NULL, N'Pending', '2026-05-30 16:28:03.298');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1078, 3098, NULL, NULL, NULL, NULL, N'Pending', '2026-05-31 19:00:26.830');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1079, 3099, NULL, NULL, NULL, NULL, N'Pending', '2026-05-31 19:07:05.185');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1080, 3100, N'31001780229850', N'15563290', N'NCB', N'00', N'Success', '2026-05-31 19:19:21.799');
INSERT INTO [PaymentTransactions] ([TransactionId], [PaymentId], [VnpayTxnRef], [TransactionNo], [BankCode], [ResponseCode], [Status], [TransactionDate]) VALUES (1081, 3101, N'31011780241623', N'15563461', N'NCB', N'00', N'Success', '2026-05-31 22:35:05.007');
SET IDENTITY_INSERT [PaymentTransactions] OFF;

-- Data for table Forecasts
SET IDENTITY_INSERT [Forecasts] ON;
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1, 12, N'Weekly', 1.00, 7.70, 0.00, 98.00, '2026-05-21 00:00:00.000', '2026-05-14 22:33:49.638');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2, 5, N'Weekly', 0.00, 0.00, 0.00, 25.00, '2026-05-21 00:00:00.000', '2026-05-14 22:34:40.320');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3, 6, N'Weekly', 0.00, 0.00, 0.00, 20.00, '2026-05-21 00:00:00.000', '2026-05-14 22:39:44.970');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (4, 1, N'Weekly', 2.00, 15.40, 9.90, 5.50, '2026-05-21 00:00:00.000', '2026-05-14 22:40:05.911');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (5, 2, N'Weekly', 2.00, 15.40, 0.00, 23.00, '2026-05-21 00:00:00.000', '2026-05-14 22:40:30.045');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (6, 17, N'Weekly', 2.00, 15.40, 0.00, 24.00, '2026-05-21 00:00:00.000', '2026-05-14 22:40:49.004');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (7, 1, N'Weekly', 2.00, 15.40, 9.90, 5.50, '2026-05-21 00:00:00.000', '2026-05-14 22:56:52.025');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1002, 2, N'Weekly', 2.50, 19.25, 0.00, 20.00, '2026-05-22 00:00:00.000', '2026-05-15 23:13:53.916');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1003, 11, N'Weekly', 1.00, 7.70, 0.00, 34.00, '2026-05-23 00:00:00.000', '2026-05-16 16:37:03.460');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1004, 1, N'Weekly', 1.54, 11.87, 0.00, 14.00, '2026-05-23 00:00:00.000', '2026-05-16 17:05:58.234');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1005, 1, N'Weekly', 1.50, 11.55, 0.00, 18.00, '2026-05-23 00:00:00.000', '2026-05-16 21:52:38.263');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1006, 4, N'Weekly', 1.67, 12.83, 7.83, 5.00, '2026-05-23 00:00:00.000', '2026-05-16 22:04:45.076');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1007, 6, N'Weekly', 1.36, 10.50, 5.50, 5.00, '2026-05-25 00:00:00.000', '2026-05-18 05:41:56.613');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1008, 17, N'Weekly', 2.38, 18.36, 17.36, 1.00, '2026-05-25 00:00:00.000', '2026-05-18 06:08:53.452');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1009, 8, N'Weekly', 2.00, 15.40, 12.40, 3.00, '2026-05-26 00:00:00.000', '2026-05-19 12:23:34.763');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1010, 6, N'Weekly', 1.31, 10.07, 0.00, 29.00, '2026-05-26 00:00:00.000', '2026-05-19 12:41:34.385');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1011, 22, N'Weekly', 1.14, 8.80, 3.80, 5.00, '2026-05-26 00:00:00.000', '2026-05-19 12:41:48.794');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (1012, 19, N'Weekly', 1.33, 10.27, 0.00, 96.00, '2026-05-26 00:00:00.000', '2026-05-19 12:45:53.720');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2009, 1, N'Weekly', 1.38, 10.63, 6.13, 4.50, '2026-05-27 00:00:00.000', '2026-05-20 08:11:52.953');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2010, 21, N'Weekly', 1.93, 14.89, 0.00, 16.00, '2026-05-27 00:00:00.000', '2026-05-20 11:46:41.022');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2011, 1009, N'Weekly', 1.25, 9.63, 0.00, 19.50, '2026-05-27 00:00:00.000', '2026-05-20 11:46:47.609');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2012, 17, N'Weekly', 2.17, 16.68, 7.68, 9.00, '2026-05-27 00:00:00.000', '2026-05-20 11:47:23.601');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2013, 17, N'Weekly', 2.17, 16.68, 7.68, 9.00, '2026-05-27 00:00:00.000', '2026-05-20 11:47:29.619');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2014, 1, N'Weekly', 1.38, 10.63, 0.00, 29.50, '2026-05-27 00:00:00.000', '2026-05-20 16:02:28.460');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2015, 14, N'Weekly', 1.63, 12.51, 0.00, 45.00, '2026-05-27 00:00:00.000', '2026-05-20 16:10:30.253');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2016, 12, N'Weekly', 1.15, 8.88, 0.00, 70.00, '2026-05-28 00:00:00.000', '2026-05-21 08:41:38.073');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2017, 17, N'Weekly', 2.05, 15.75, 12.75, 3.00, '2026-05-28 00:00:00.000', '2026-05-21 08:42:15.573');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2018, 1050, N'Weekly', 1.41, 10.86, 8.16, 2.70, '2026-05-28 00:00:00.000', '2026-05-21 09:02:41.480');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2019, 10, N'Weekly', 1.25, 9.63, 0.00, 33.50, '2026-05-29 00:00:00.000', '2026-05-22 09:12:29.990');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2020, 17, N'Weekly', 1.96, 15.08, 14.08, 1.00, '2026-05-29 00:00:00.000', '2026-05-22 09:27:58.390');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2021, 16, N'Weekly', 1.19, 9.14, 5.14, 4.00, '2026-05-29 00:00:00.000', '2026-05-22 09:47:58.415');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2022, 17, N'Weekly', 1.87, 14.37, 0.00, 92.00, '2026-05-29 00:00:00.000', '2026-05-22 09:51:40.622');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2023, 2, N'3 Days', 1.58, 5.38, 0.00, 9.00, '2026-05-25 00:00:00.000', '2026-05-22 21:43:43.661');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2024, 1, N'3 Days', 1.21, 4.25, 0.00, 15.00, '2026-05-26 00:00:00.000', '2026-05-23 08:17:21.669');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2025, 5, N'5 Days', 1.44, 8.00, 0.60, 9.00, '2026-05-28 00:00:00.000', '2026-05-23 08:25:15.516');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2026, 21, N'3 Days', 1.79, 5.89, 0.00, 50.00, '2026-05-26 00:00:00.000', '2026-05-23 14:33:47.271');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2027, 2, N'3 Days', 1.58, 5.36, 0.00, 7.50, '2026-05-26 00:00:00.000', '2026-05-23 14:34:12.814');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2028, 1, N'3 Days', 1.18, 4.11, 0.00, 5.50, '2026-05-26 00:00:00.000', '2026-05-23 14:47:29.545');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2029, 1, N'3 Days', 1.18, 4.11, 0.00, 5.50, '2026-05-26 00:00:00.000', '2026-05-23 15:00:29.795');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2030, 1, N'3 Days', 1.18, 4.11, 4.43, 0.50, '2026-05-26 00:00:00.000', '2026-05-23 15:09:30.581');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2031, 1062, N'Weekly', 1.50, 11.55, 0.00, 22.00, '2026-05-30 00:00:00.000', '2026-05-23 15:48:17.464');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2032, 1028, N'5 Days', 1.08, 5.92, 0.00, 32.00, '2026-05-28 00:00:00.000', '2026-05-23 15:48:46.891');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2033, 5, N'5 Days', 1.29, 7.24, 0.00, 34.00, '2026-05-28 00:00:00.000', '2026-05-23 15:54:16.578');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2034, 8, N'5 Days', 2.61, 14.76, 0.00, 48.00, '2026-05-29 00:00:00.000', '2026-05-24 15:33:40.961');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (2035, 2, N'3 Days', 1.58, 5.33, 0.00, 19.70, '2026-05-27 00:00:00.000', '2026-05-24 16:35:51.135');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3034, 1, N'3 Days', 1.17, 4.03, 0.00, 15.10, '2026-05-28 00:00:00.000', '2026-05-25 14:52:09.182');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3035, 6, N'3 Days', 1.20, 3.96, 0.75, 4.00, '2026-05-28 00:00:00.000', '2026-05-25 14:52:44.519');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3036, 1, N'3 Days', 1.17, 4.03, 0.00, 15.10, '2026-05-29 00:00:00.000', '2026-05-26 11:00:58.439');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3037, 8, N'3 Days', 2.38, 8.10, 0.00, 45.00, '2026-05-29 00:00:00.000', '2026-05-26 11:01:33.771');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3038, 2, N'3 Days', 1.40, 4.82, 0.00, 56.70, '2026-05-31 00:00:00.000', '2026-05-28 11:29:28.431');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3039, 3, N'3 Days', 1.51, 5.34, 0.00, 21.30, '2026-05-31 00:00:00.000', '2026-05-28 11:44:09.035');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3040, 4, N'3 Days', 1.30, 4.35, 0.00, 11.00, '2026-05-31 00:00:00.000', '2026-05-28 11:52:44.751');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3041, 12, N'3 Days', 1.06, 3.51, 0.00, 18.00, '2026-05-31 00:00:00.000', '2026-05-28 11:53:03.806');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3042, 1028, N'3 Days', 1.06, 3.48, 0.00, 27.00, '2026-05-31 00:00:00.000', '2026-05-28 11:53:19.668');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3043, 1021, N'Weekly', 1.20, 9.24, 0.00, 24.00, '2026-06-04 00:00:00.000', '2026-05-28 12:19:48.126');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3044, 1004, N'3 Days', 1.05, 3.47, 0.00, 16.00, '2026-05-31 00:00:00.000', '2026-05-28 12:20:05.621');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3045, 1, N'3 Days', 1.13, 3.84, 0.00, 87.60, '2026-06-01 00:00:00.000', '2026-05-29 10:46:53.414');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3046, 4, N'3 Days', 1.33, 4.45, 0.00, 9.00, '2026-06-01 00:00:00.000', '2026-05-29 11:06:09.435');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3047, 4, N'Weekly', 0.87, 7.44, 0.00, 9.00, '2026-06-05 00:00:00.000', '2026-05-29 12:06:07.062');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3048, 2, N'5 Days', 2.10, 14.39, 0.00, 52.70, '2026-06-03 00:00:00.000', '2026-05-29 12:06:42.146');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3049, 1, N'5 Days', 3.50, 20.72, 0.00, 87.60, '2026-06-04 00:00:00.000', '2026-05-30 09:19:28.595');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3050, 5, N'5 Days', 1.33, 7.88, 0.00, 16.00, '2026-06-04 00:00:00.000', '2026-05-30 10:37:10.319');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3051, 1025, N'Weekly', 0.23, 1.80, 0.00, 36.00, '2026-06-07 00:00:00.000', '2026-05-31 12:01:48.725');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3052, 3, N'5 Days', 1.19, 7.26, 0.00, 18.90, '2026-06-05 00:00:00.000', '2026-05-31 12:09:58.585');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3053, 4, N'Weekly', 0.97, 8.21, 2.86, 7.00, '2026-06-07 00:00:00.000', '2026-05-31 12:10:08.216');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3054, 6, N'5 Days', 2.10, 11.73, 10.08, 4.00, '2026-06-05 00:00:00.000', '2026-05-31 15:45:24.062');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3055, 1067, N'Weekly', 0.13, 1.03, 0.00, 5.00, '2026-06-07 00:00:00.000', '2026-05-31 15:46:56.213');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3056, 1051, N'Weekly', 0.17, 1.28, 0.00, 4.00, '2026-06-07 00:00:00.000', '2026-05-31 15:47:15.750');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3057, 21, N'5 Days', 3.10, 17.23, 18.68, 2.00, '2026-06-05 00:00:00.000', '2026-05-31 15:48:07.041');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3058, 1, N'5 Days', 3.90, 23.10, 0.00, 79.50, '2026-06-06 00:00:00.000', '2026-06-01 02:33:26.764');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3059, 5, N'5 Days', 1.33, 7.88, 0.00, 16.00, '2026-06-06 00:00:00.000', '2026-06-01 02:33:49.012');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3060, 10, N'5 Days', 1.48, 9.08, 4.39, 6.50, '2026-06-06 00:00:00.000', '2026-06-01 02:34:06.014');
INSERT INTO [Forecasts] ([ForecastId], [ProductId], [ForecastType], [AvgDailySales], [PredictQuantity], [SuggestReStock], [CurrentStock], [ForecastDate], [GeneratedAt]) VALUES (3061, 12, N'5 Days', 2.98, 16.96, 9.85, 10.50, '2026-06-06 00:00:00.000', '2026-06-01 02:34:26.681');
SET IDENTITY_INSERT [Forecasts] OFF;


