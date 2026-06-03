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
    [CategoryName] varchar(50) NOT NULL,
    [IsActive] bit NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY ([CategoryId])
);
GO

CREATE TABLE [Packages] (
    [PackageId] int NOT NULL IDENTITY,
    [PackageCode] varchar(50) NOT NULL,
    [PackageName] varchar(50) NOT NULL,
    [ImageUrl] varchar(255) NULL,
    [Description] varchar(255) NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [StartDate] datetime2 NULL,
    [EndDate] datetime2 NULL,
    [Discount] decimal(18,2) NULL,
    [MaxQuantity] int NULL,
    [RowVersion] rowversion NULL,
    [IsActive] bit NULL,
    CONSTRAINT [PK_Packages] PRIMARY KEY ([PackageId])
);
GO

CREATE TABLE [Roles] (
    [RoleId] int NOT NULL IDENTITY,
    [RoleName] varchar(20) NOT NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([RoleId])
);
GO

CREATE TABLE [Products] (
    [ProductId] int NOT NULL IDENTITY,
    [ProductCode] varchar(50) NOT NULL,
    [ProductName] varchar(100) NOT NULL,
    [Unit] varchar(50) NOT NULL,
    [IsActive] bit NULL,
    [CategoryId] int NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([ProductId]),
    CONSTRAINT [FK_Products_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([CategoryId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Users] (
    [UserId] int NOT NULL IDENTITY,
    [FullName] varchar(100) NOT NULL,
    [Email] varchar(100) NOT NULL,
    [Password] varchar(255) NOT NULL,
    [PhoneNumber] varchar(10) NOT NULL,
    [CreateAt] datetime2 NULL,
    [IsActive] bit NULL,
    [RoleId] int NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([UserId]),
    CONSTRAINT [FK_Users_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([RoleId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Forecasts] (
    [ForecastId] int NOT NULL IDENTITY,
    [ProductId] int NULL,
    [ForecastType] varchar(50) NULL,
    [AvgDailySales] decimal(18,2) NULL,
    [PredictQuantity] decimal(18,2) NULL,
    [SuggestStock] decimal(18,2) NULL,
    [CurrentStock] decimal(18,2) NULL,
    [ForecastDate] datetime2 NULL,
    [GeneratedAt] datetime2 NULL,
    CONSTRAINT [PK_Forecasts] PRIMARY KEY ([ForecastId]),
    CONSTRAINT [FK_Forecasts_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Inventories] (
    [InventoryId] int NOT NULL IDENTITY,
    [ProductId] int NULL,
    [QtyInStock] decimal(18,2) NOT NULL,
    [MinStock] decimal(18,2) NOT NULL,
    [LastUpdated] datetime2 NULL,
    [RowVersion] rowversion NOT NULL,
    CONSTRAINT [PK_Inventories] PRIMARY KEY ([InventoryId]),
    CONSTRAINT [FK_Inventories_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [PackageItems] (
    [PackageItemId] int NOT NULL IDENTITY,
    [PackageId] int NULL,
    [ProductId] int NULL,
    [PackageQty] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_PackageItems] PRIMARY KEY ([PackageItemId]),
    CONSTRAINT [FK_PackageItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_PackageItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([ProductId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Carts] (
    [CartId] int NOT NULL IDENTITY,
    [TotalPrice] decimal(18,2) NULL,
    [UserId] int NULL,
    CONSTRAINT [PK_Carts] PRIMARY KEY ([CartId]),
    CONSTRAINT [FK_Carts_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([UserId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Orders] (
    [OrderId] int NOT NULL IDENTITY,
    [OrderCode] varchar(50) NULL,
    [ReceiveName] varchar(50) NOT NULL,
    [ReceivePhone] varchar(10) NOT NULL,
    [ReceiveAddress] varchar(255) NOT NULL,
    [ShipmentPrice] decimal(18,2) NOT NULL,
    [OrderDate] datetime2 NULL,
    [OrderStatus] varchar(50) NULL,
    [TotalAmount] decimal(18,2) NULL,
    [UserId] int NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([OrderId]),
    CONSTRAINT [FK_Orders_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([UserId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [InventoryTransactions] (
    [TransactionId] int NOT NULL IDENTITY,
    [InventoryId] int NULL,
    [PackageId] int NULL,
    [QuantityChange] decimal(18,2) NOT NULL,
    [Note] varchar(50) NOT NULL,
    [TransactionDate] datetime2 NULL,
    [TransactionType] varchar(max) NOT NULL,
    CONSTRAINT [PK_InventoryTransactions] PRIMARY KEY ([TransactionId]),
    CONSTRAINT [FK_InventoryTransactions_Inventories_InventoryId] FOREIGN KEY ([InventoryId]) REFERENCES [Inventories] ([InventoryId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_InventoryTransactions_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE SET NULL
);
GO

CREATE TABLE [CartItems] (
    [CartItemId] int NOT NULL IDENTITY,
    [CartId] int NULL,
    [CartQuantity] int NULL,
    [CartPrice] decimal(18,2) NULL,
    [PackageId] int NULL,
    CONSTRAINT [PK_CartItems] PRIMARY KEY ([CartItemId]),
    CONSTRAINT [FK_CartItems_Carts_CartId] FOREIGN KEY ([CartId]) REFERENCES [Carts] ([CartId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_CartItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [OrderItems] (
    [OrderItemId] int NOT NULL IDENTITY,
    [OrderId] int NULL,
    [PackageId] int NULL,
    [OrderPrice] decimal(18,2) NULL,
    [OrderQuantity] int NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([OrderItemId]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([OrderId]) ON DELETE NO ACTION,
    CONSTRAINT [FK_OrderItems_Packages_PackageId] FOREIGN KEY ([PackageId]) REFERENCES [Packages] ([PackageId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Payments] (
    [PaymentId] int NOT NULL IDENTITY,
    [OrderId] int NULL,
    [PaymentMethod] varchar(50) NULL,
    [Amount] decimal(18,2) NULL,
    [PaymentStatus] varchar(50) NULL,
    [CreatedAt] datetime2 NULL,
    [UpdatedAt] datetime2 NULL,
    CONSTRAINT [PK_Payments] PRIMARY KEY ([PaymentId]),
    CONSTRAINT [FK_Payments_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([OrderId]) ON DELETE NO ACTION
);
GO

CREATE TABLE [PaymentTransactions] (
    [TransactionId] int NOT NULL IDENTITY,
    [PaymentId] int NULL,
    [VnpayTxnRef] varchar(100) NULL,
    [TransactionNo] varchar(50) NULL,
    [BankCode] varchar(20) NULL,
    [ResponseCode] varchar(10) NULL,
    [Status] varchar(50) NULL,
    [TransactionDate] datetime2 NULL,
    CONSTRAINT [PK_PaymentTransactions] PRIMARY KEY ([TransactionId]),
    CONSTRAINT [FK_PaymentTransactions_Payments_PaymentId] FOREIGN KEY ([PaymentId]) REFERENCES [Payments] ([PaymentId]) ON DELETE NO ACTION
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

CREATE INDEX [IX_PaymentTransactions_PaymentId] ON [PaymentTransactions] ([PaymentId]);
GO

CREATE INDEX [IX_Products_CategoryId] ON [Products] ([CategoryId]);
GO

CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]);
GO

CREATE INDEX [IX_Users_RoleId] ON [Users] ([RoleId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260603101503_Initial', N'8.0.11');
GO

COMMIT;
GO
