-- =====================================================================
-- Petstore Lite database schema (Apache Derby 10.14, runtime)
-- Schema: ESTOREUSER   Database: PetStoreDB
-- Source of truth for table shape: src/main/webapp/populate/PopulateSQL.xml
-- (the PopulateServlet creates these tables on first load).
-- Catalog tables come from Java Pet Store 1.3.2. SIGNON replaces the
-- User CMP entity bean table. SIGNON_AUDIT is the sign-on transaction log.
-- =====================================================================

-- CATEGORY: Pet categories (FISH, DOGS, REPTILES, CATS, BIRDS). Key only; text is in CATEGORY_DETAILS.
CREATE TABLE category (catid char(10) not null,
  constraint pk_category primary key (catid));

-- CATEGORY_DETAILS: Localised name, image and description of a category. One row per category and locale.
CREATE TABLE category_details (catid char(10) not null,
  name varchar(80) not null, image varchar(255),
  descn varchar(255), locale char(10) not null,
  constraint pk_category_details primary key (catid, locale),
    constraint fk_category_details_1 foreign key (catid)
    references category (catid));

-- PRODUCT: A kind of pet within a category, for example K9-BD-01 Bulldog in DOGS.
CREATE TABLE product (
  productid char(10) not null,
  catid char(10) not null,
  constraint pk_product primary key (productid),
    constraint fk_product_1 foreign key (catid)
    references category (catid));

-- PRODUCT_DETAILS: Localised name, image and description of a product.
CREATE TABLE product_details (
  productid char(10) not null,
  locale char(10) not null,
  name varchar(80) not null,
  image varchar(255),
  descn varchar(255),
  constraint pk_product_details primary key (productid, locale),
    constraint fk_product_details_1 foreign key (productid)
    references product (productid));

-- ITEM: A sellable variant of a product, for example EST-6 Male Adult Bulldog.
CREATE TABLE item (
  itemid char(10) not null,
  productid char(10) not null,
  constraint pk_item primary key (itemid),
    constraint fk_item_1 foreign key (productid)
    references product (productid)
);

-- ITEM_DETAILS: Localised price, cost, image, description and up to 5 attributes of an item. List price must not be below unit cost.
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
      constraint fk_item_details_1 foreign key (itemid)
      references item (itemid),
      constraint ck_item_details_price check (listprice >= unitcost)
);

-- SIGNON: Sign-on accounts. Role is CUSTOMER or ADMIN. Locked after 3 failed sign-ons in a row; unlocked by PSL_ACCT_UNLOCK after 30 minutes.
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

-- SIGNON_AUDIT: Transaction log of sign-on events. Extracted daily by PSL_AUDIT_EXTRACT, purged after 90 days by PSL_AUDIT_PURGE.
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

CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
