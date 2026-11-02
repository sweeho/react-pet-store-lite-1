-- PSL_CATALOG_CHECK: catalog integrity checks. Each query must return 0 rows
-- or a zero count; the script fails the job otherwise.
-- C1: categories with no product
SELECT 'C1' AS chk, c.catid FROM category c
 WHERE NOT EXISTS (SELECT 1 FROM product p WHERE p.catid = c.catid);
-- C2: products with no item
SELECT 'C2' AS chk, p.productid FROM product p
 WHERE NOT EXISTS (SELECT 1 FROM item i WHERE i.productid = p.productid);
-- C3: items priced below cost
SELECT 'C3' AS chk, itemid FROM item_details WHERE listprice < unitcost;
-- C4: items without an en_US description
SELECT 'C4' AS chk, i.itemid FROM item i
 WHERE NOT EXISTS (SELECT 1 FROM item_details d WHERE d.itemid = i.itemid AND d.locale = 'en_US');
-- Totals for the log
SELECT COUNT(*) AS categories FROM category;
SELECT COUNT(*) AS items FROM item;
