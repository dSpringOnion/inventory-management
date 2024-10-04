-- Create Enums
-- LevelEnum: MANAGER, AREA_MANAGER, ADMIN
CREATE TYPE "LevelEnum" AS ENUM ('MANAGER', 'AREA_MANAGER', 'ADMIN');

-- ContactMethodEnum: PHONE, EMAIL, WECHAT
CREATE TYPE "ContactMethodEnum" AS ENUM ('PHONE', 'EMAIL', 'WECHAT');

-- Create Table: User
CREATE TABLE "User" (
                        "id" TEXT NOT NULL PRIMARY KEY,
                        "name" TEXT NOT NULL,
                        "email" TEXT NOT NULL UNIQUE,
                        "password" TEXT NOT NULL,
                        "permission" "LevelEnum" NOT NULL DEFAULT 'MANAGER',
                        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create Table: Store
CREATE TABLE "Store" (
                         "id" TEXT NOT NULL PRIMARY KEY,
                         "name" TEXT NOT NULL,
                         "address" TEXT NOT NULL,
                         "contactMethod" "ContactMethodEnum" NOT NULL,
                         "userId" TEXT NOT NULL,
                         "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                         "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                         CONSTRAINT "Store_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Table: Vendor
CREATE TABLE "Vendor" (
                          "id" TEXT NOT NULL PRIMARY KEY,
                          "name" TEXT NOT NULL,
                          "address" TEXT NOT NULL,
                          "contactMethod" "ContactMethodEnum" NOT NULL,
                          "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                          "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create Table: Item
CREATE TABLE "Item" (
                        "itemId" TEXT NOT NULL PRIMARY KEY,
                        "nameEn" TEXT NOT NULL,
                        "nameZh" TEXT NOT NULL,
                        "price" DECIMAL(10, 2) NOT NULL,
                        "description" TEXT NOT NULL,
                        "onHand" INTEGER NOT NULL,
                        "minStock" INTEGER NOT NULL,
                        "vendorId" TEXT NOT NULL,
                        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                        CONSTRAINT "Item_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "Vendor"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Table: Invoice
CREATE TABLE "Invoice" (
                           "invoiceId" TEXT NOT NULL PRIMARY KEY,
                           "date" TIMESTAMP WITH TIME ZONE NOT NULL,
                           "totalCost" DECIMAL(10, 2) NOT NULL,
                           "vendorId" TEXT NOT NULL,
                           "userId" TEXT NOT NULL,
                           "storeId" TEXT NOT NULL,
                           "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                           "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                           CONSTRAINT "Invoice_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "Vendor"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
                           CONSTRAINT "Invoice_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
                           CONSTRAINT "Invoice_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Table: InvoiceItem
CREATE TABLE "InvoiceItem" (
                               "id" TEXT NOT NULL PRIMARY KEY,
                               "invoiceID" TEXT NOT NULL,
                               "itemId" TEXT NOT NULL,
                               "quantity" INTEGER NOT NULL,
                               "unitCost" DECIMAL(10, 2) NOT NULL,
                               "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                               "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                               CONSTRAINT "InvoiceItem_invoiceID_fkey" FOREIGN KEY ("invoiceID") REFERENCES "Invoice"("invoiceId") ON DELETE RESTRICT ON UPDATE CASCADE,
                               CONSTRAINT "InvoiceItem_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "Item"("itemId") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Table: StoreItem (Many-to-Many Relationship between Store and Item)
CREATE TABLE "StoreItem" (
                             "storeId" TEXT NOT NULL,
                             "itemId" TEXT NOT NULL,
                             PRIMARY KEY ("storeId", "itemId"),
                             CONSTRAINT "StoreItem_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
                             CONSTRAINT "StoreItem_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "Item"("itemId") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Indexes for Foreign Key Columns (Optional for Performance)
CREATE INDEX "Store_userId_idx" ON "Store" ("userId");
CREATE INDEX "Item_vendorId_idx" ON "Item" ("vendorId");
CREATE INDEX "Invoice_vendorId_idx" ON "Invoice" ("vendorId");
CREATE INDEX "Invoice_userId_idx" ON "Invoice" ("userId");
CREATE INDEX "Invoice_storeId_idx" ON "Invoice" ("storeId");
CREATE INDEX "InvoiceItem_invoiceID_idx" ON "InvoiceItem" ("invoiceID");
CREATE INDEX "InvoiceItem_itemId_idx" ON "InvoiceItem" ("itemId");
CREATE INDEX "StoreItem_storeId_idx" ON "StoreItem" ("storeId");
CREATE INDEX "StoreItem_itemId_idx" ON "StoreItem" ("itemId");

-- Triggers to Update 'updatedAt' Field on Record Update (Optional)
-- For the 'User' table
CREATE OR REPLACE FUNCTION update_User_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "User_updatedAt_trg"
    BEFORE UPDATE ON "User"
    FOR EACH ROW
    EXECUTE PROCEDURE update_User_updatedAt();

-- Repeat the trigger creation for other tables as needed
-- For 'Store' table
CREATE OR REPLACE FUNCTION update_Store_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Store_updatedAt_trg"
    BEFORE UPDATE ON "Store"
    FOR EACH ROW
    EXECUTE PROCEDURE update_Store_updatedAt();

-- For 'Vendor' table
CREATE OR REPLACE FUNCTION update_Vendor_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Vendor_updatedAt_trg"
    BEFORE UPDATE ON "Vendor"
    FOR EACH ROW
    EXECUTE PROCEDURE update_Vendor_updatedAt();

-- For 'Item' table
CREATE OR REPLACE FUNCTION update_Item_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Item_updatedAt_trg"
    BEFORE UPDATE ON "Item"
    FOR EACH ROW
    EXECUTE PROCEDURE update_Item_updatedAt();

-- For 'Invoice' table
CREATE OR REPLACE FUNCTION update_Invoice_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "Invoice_updatedAt_trg"
    BEFORE UPDATE ON "Invoice"
    FOR EACH ROW
    EXECUTE PROCEDURE update_Invoice_updatedAt();

-- For 'InvoiceItem' table
CREATE OR REPLACE FUNCTION update_InvoiceItem_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "InvoiceItem_updatedAt_trg"
    BEFORE UPDATE ON "InvoiceItem"
    FOR EACH ROW
    EXECUTE PROCEDURE update_InvoiceItem_updatedAt();

-- For 'StoreItem' table (if you want to track updates)
CREATE OR REPLACE FUNCTION update_StoreItem_updatedAt()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Since 'StoreItem' only has two columns (composite primary key), you might not need an 'updatedAt' field or trigger.

-- Optional: If you prefer to have default values for 'createdAt' and 'updatedAt' set at the database level
-- (These defaults are already included in the table definitions)

-- Ensuring that 'email' in 'User' table is unique
ALTER TABLE "User"
    ADD CONSTRAINT "User_email_key" UNIQUE ("email");

-- You can add similar UNIQUE constraints to other tables if needed

-- Additional Foreign Key Constraints (Already included in table definitions)

-- Note: All foreign key constraints have 'ON DELETE RESTRICT ON UPDATE CASCADE' behavior.
-- You can adjust these behaviors based on your application's needs.