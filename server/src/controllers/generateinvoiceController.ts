// controllers/generateInvoiceController.ts

import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

interface SelectedItem {
    itemId: string;
    quantity: number;
}

export async function generateInvoiceController(
    userId: string,
    storeId: string,
    selectedItems: SelectedItem[]
) {
    // Start a database transaction
    return await prisma.$transaction(async (prisma) => {
        // Step 1: Fetch item details and group by vendor
        const itemsWithVendor = await prisma.item.findMany({
            where: {
                itemId: { in: selectedItems.map((item) => item.itemId) },
            },
            select: {
                itemId: true,
                vendorId: true,
                price: true,
            },
        });

        if (itemsWithVendor.length === 0) {
            throw new Error('No items found with the provided item IDs');
        }

        // Create a map for quick access to item details
        const itemMap = new Map<string, { vendorId: string; price: number }>();
        itemsWithVendor.forEach((item) => {
            itemMap.set(item.itemId, { vendorId: item.vendorId, price: Number(item.price) });
        });

        // Group selected items by vendor
        const itemsGroupedByVendor: { [vendorId: string]: SelectedItem[] } = {};
        selectedItems.forEach((selectedItem) => {
            const itemDetail = itemMap.get(selectedItem.itemId);
            if (!itemDetail) {
                throw new Error(`Item with ID ${selectedItem.itemId} not found`);
            }
            const vendorId = itemDetail.vendorId;
            if (!itemsGroupedByVendor[vendorId]) {
                itemsGroupedByVendor[vendorId] = [];
            }
            itemsGroupedByVendor[vendorId].push(selectedItem);
        });

        // Step 2: Generate invoices for each vendor
        const invoices = [];

        for (const [vendorId, vendorItems] of Object.entries(itemsGroupedByVendor)) {
            // Create a new invoice
            const invoiceId = uuidv4();
            const invoice = await prisma.invoice.create({
                data: {
                    invoiceId,
                    date: new Date(),
                    totalCost: 0, // We'll update this later
                    vendorId,
                    userId,
                    storeId,
                    invoiceItems: {
                        create: [], // We'll populate this shortly
                    },
                },
            });

            let totalCost = 0;

            // Prepare invoice items
            const invoiceItemsData = vendorItems.map((selectedItem) => {
                const itemDetail = itemMap.get(selectedItem.itemId);
                if (!itemDetail) {
                    throw new Error(`Item with ID ${selectedItem.itemId} not found`);
                }
                const unitCost = itemDetail.price;
                const cost = unitCost * selectedItem.quantity;
                totalCost += cost;

                return {
                    id: uuidv4(),
                    itemId: selectedItem.itemId,
                    quantity: selectedItem.quantity,
                    unitCost,
                };
            });

            // Create invoice items
            await prisma.invoiceItem.createMany({
                data: invoiceItemsData.map((item) => ({
                    ...item,
                    invoiceID: invoice.invoiceId,
                    createdAt: new Date(),
                    updatedAt: new Date(),
                })),
            });

            // Update the total cost of the invoice
            await prisma.invoice.update({
                where: { invoiceId: invoice.invoiceId },
                data: { totalCost },
            });

            invoices.push({
                invoiceId: invoice.invoiceId,
                vendorId,
                totalCost,
                items: invoiceItemsData,
            });
        }

        return invoices;
    });
}