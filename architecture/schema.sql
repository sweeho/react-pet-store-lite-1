-- EXTRACTED FROM LEGACY SOURCE — evidence of what exists, not a build target. Where this disagrees with a capability delta spec, the delta spec wins.
--
-- Spec extraction SX-0001. This is the data model of the legacy Java Pet Store Lite
-- (J2EE, Apache Derby 10.14 at runtime, Oracle 19c as reference production), copied from:
--   legacy-source/j2ee-pet-store-lite/db/schema/petstore_derby.sql   (lines 1-107)
--   legacy-source/j2ee-pet-store-lite/db/schema/petstore_oracle.sql  (lines 1-134)
--   legacy-source/j2ee-pet-store-lite/src/main/webapp/populate/PopulateSQL.xml (the
--     statements the populate servlet actually runs to create these tables)
-- It is written in the Derby dialect the legacy application runs. It is NOT a Drizzle
-- schema and NOT a migration for this repository: the rebuild's schema lives in db/ and
-- drizzle/, derived from the capability delta specs under openspec/changes/sx-*/.
--
-- Dialect differences between the legacy sources (recorded, not resolved):
--   D1. Key columns are char(10) in Derby and varchar(10) in Oracle. char(10) pads
--       identifiers with trailing spaces (CDI-RULE-0006, held for an SME decision).
--   D2. signon_audit.audit_id is "generated always as identity" in Derby. The Oracle
--       schema file generates it with sequence signon_audit_seq and trigger
--       trg_signon_audit_id, but the Oracle statements in PopulateSQL.xml (lines 352-363)
--       create the table with neither, so an insert that omits audit_id fails on a
--       store populated through the servlet on Oracle. Disputed; see sign-on-audit and
--       sample-data-population delta specs.
--   D3. Oracle uses number(10,2) / number(3) / varchar2 where Derby uses decimal / integer /
--       varchar. Precision is the same.
--   D4. signon_audit.username has no foreign key to signon: failed sign-ins for unknown
--       user names are recorded with the name exactly as typed.
--   D5. signon.password is stored and compared as entered (no hash). The capability spec
--       sign-on carries this as a Business Owner decision; do not copy it.

-- CATEGORY: Pet categories (FISH, DOGS, REPTILES, CATS, BIRDS). Key only; text is in CATEGORY_DETAILS.
CREATE TABLE category (
  catid char(10) not null,
  constraint pk_category primary key (catid)
);

-- CATEGORY_DETAILS: Localised name, image and description of a category. One row per category and locale.
CREATE TABLE category_details (
  catid char(10) not null,
  name varchar(80) not null,
  image varchar(255),
  descn varchar(255),
  locale char(10) not null,
  constraint pk_category_details primary key (catid, locale),
  constraint fk_category_details_1 foreign key (catid) references category (catid)
);

-- PRODUCT: A kind of pet within a category, for example K9-BD-01 Bulldog in DOGS.
CREATE TABLE product (
  productid char(10) not null,
  catid char(10) not null,
  constraint pk_product primary key (productid),
  constraint fk_product_1 foreign key (catid) references category (catid)
);

-- PRODUCT_DETAILS: Localised name, image and description of a product.
CREATE TABLE product_details (
  productid char(10) not null,
  locale char(10) not null,
  name varchar(80) not null,
  image varchar(255),
  descn varchar(255),
  constraint pk_product_details primary key (productid, locale),
  constraint fk_product_details_1 foreign key (productid) references product (productid)
);

-- ITEM: A sellable variant of a product, for example EST-6 Male Adult Bulldog.
CREATE TABLE item (
  itemid char(10) not null,
  productid char(10) not null,
  constraint pk_item primary key (itemid),
  constraint fk_item_1 foreign key (productid) references product (productid)
);

-- ITEM_DETAILS: Localised price, cost, image, description and up to 5 attributes of an item.
-- listprice is shown as "List Price"; unitcost is shown as "Your Price" (Oracle column comments).
CREATE TABLE item_details (
  itemid char(10) not null,
  listprice decimal(10,2) not null,
  unitcost decimal(10,2) not null,
  locale char(10) not null,
  image varchar(255) not null,
  descn varchar(255) not null,
  attr1 varchar(80),
  attr2 varchar(80),
  attr3 varchar(80),
  attr4 varchar(80),
  attr5 varchar(80),
  constraint pk_item_details primary key (itemid, locale),
  constraint fk_item_details_1 foreign key (itemid) references item (itemid),
  constraint ck_item_details_price check (listprice >= unitcost)
);

-- SIGNON: Sign-on accounts. Role is CUSTOMER or ADMIN. Locked after 3 failed sign-ons in a row;
-- unlocked by the PSL_ACCT_UNLOCK batch job once the lock is more than 30 minutes old.
-- failed_attempts: consecutive failed sign-ons, reset to 0 on success or unlock.
-- locked: Y when the account is locked, else N.
CREATE TABLE signon (
  username varchar(25) not null,
  password varchar(25) not null,
  role varchar(10) default 'CUSTOMER' not null,
  failed_attempts integer default 0 not null,
  locked char(1) default 'N' not null,
  locked_ts timestamp,
  last_signon timestamp,
  created_ts timestamp default current_timestamp not null,
  constraint pk_signon primary key (username),
  constraint ck_signon_role check (role in ('CUSTOMER', 'ADMIN')),
  constraint ck_signon_locked check (locked in ('Y', 'N'))
);

-- SIGNON_AUDIT: Transaction log of sign-on events. Extracted daily by PSL_AUDIT_EXTRACT,
-- purged after 90 days by PSL_AUDIT_PURGE. remote_addr holds the client address, or the
-- literal 'batch:PSL_ACCT_UNLOCK' (db/batch/acct_unlock.sql:7) or 'admin'
-- (docs/guides/admin-guide.html:65) for unlocks written by the batch job or by an operator.
CREATE TABLE signon_audit (
  audit_id bigint generated always as identity,
  username varchar(25) not null,
  event_type varchar(20) not null,
  event_ts timestamp not null,
  remote_addr varchar(45),
  constraint pk_signon_audit primary key (audit_id),
  constraint ck_signon_audit_event check (event_type in
    ('SIGNON_OK', 'SIGNON_FAIL', 'SIGNON_LOCKED', 'ACCOUNT_LOCKED', 'SIGNOFF', 'USER_CREATED', 'ACCOUNT_UNLOCKED'))
);

CREATE INDEX idx_product_catid ON product (catid);
CREATE INDEX idx_item_productid ON item (productid);
CREATE INDEX idx_signon_audit_user_ts ON signon_audit (username, event_ts);
CREATE INDEX idx_signon_audit_ts ON signon_audit (event_ts);

-- V_CATALOG_ITEM: combined catalog view. No reader was found in the legacy source
-- (CDI-RULE-0002, disputed: unresolved reachability).
CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
