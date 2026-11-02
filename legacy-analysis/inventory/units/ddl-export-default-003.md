# Unit ddl-export-default-003

Read through the DDL export adapter (ddl-export@1.0.0). 16 item(s). Cite each requirement with the trace kind, path and anchor given for its item.

## table signon

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `signon`
- lines: 70-82

```sql
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
```

## table signon_audit

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `signon_audit`
- lines: 85-94

```sql
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
```

## view v_catalog_item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `v_catalog_item`
- lines: 101-109
- touches: reads item, reads item_details, reads product, reads product_details, reads category, reads category_details

```sql
CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
```

## table signon

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `signon`
- lines: 70-82

```sql
CREATE TABLE signon (
  username varchar2(25) not null,
  password varchar2(25) not null,
  role varchar2(10) default 'CUSTOMER' not null,
  failed_attempts number(3) default 0 not null,
  locked char(1) default 'N' not null,
  locked_ts timestamp,
  last_signon timestamp,
  created_ts timestamp default current_timestamp not null,
  constraint pk_signon primary key (username),
  constraint ck_signon_role check (role in ('CUSTOMER', 'ADMIN')),
  constraint ck_signon_locked check (locked in ('Y', 'N'))
);
```

## table signon_audit

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `signon_audit`
- lines: 85-94

```sql
CREATE TABLE signon_audit (
  audit_id number(19) not null,
  username varchar2(25) not null,
  event_type varchar2(20) not null,
  event_ts timestamp not null,
  remote_addr varchar2(45),
  constraint pk_signon_audit primary key (audit_id),
  constraint ck_signon_audit_event check (event_type in
    ('SIGNON_OK', 'SIGNON_FAIL', 'SIGNON_LOCKED', 'ACCOUNT_LOCKED', 'SIGNOFF', 'USER_CREATED', 'ACCOUNT_UNLOCKED'))
);
```

## sequence signon_audit_seq

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `signon_audit_seq`
- lines: 96-96

```sql
CREATE SEQUENCE signon_audit_seq START WITH 1 INCREMENT BY 1 CACHE 20;
```

## trigger trg_signon_audit_id

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `trg_signon_audit_id`
- lines: 98-104
- touches: writes signon_audit

```sql
CREATE OR REPLACE TRIGGER trg_signon_audit_id
BEFORE INSERT ON signon_audit
FOR EACH ROW
WHEN (new.audit_id IS NULL)
BEGIN
  SELECT signon_audit_seq.NEXTVAL INTO :new.audit_id FROM dual;
END;
```

## view v_catalog_item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `v_catalog_item`
- lines: 112-120
- touches: reads item, reads item_details, reads product, reads product_details, reads category, reads category_details

```sql
CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
```

## table signon

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `signon`
- lines: 70-82

```sql
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
```

## table signon_audit

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `signon_audit`
- lines: 85-94

```sql
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
```

## view v_catalog_item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `v_catalog_item`
- lines: 101-109
- touches: reads item, reads item_details, reads product, reads product_details, reads category, reads category_details

```sql
CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
```

## table signon

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `signon`
- lines: 70-82

```sql
CREATE TABLE signon (
  username varchar2(25) not null,
  password varchar2(25) not null,
  role varchar2(10) default 'CUSTOMER' not null,
  failed_attempts number(3) default 0 not null,
  locked char(1) default 'N' not null,
  locked_ts timestamp,
  last_signon timestamp,
  created_ts timestamp default current_timestamp not null,
  constraint pk_signon primary key (username),
  constraint ck_signon_role check (role in ('CUSTOMER', 'ADMIN')),
  constraint ck_signon_locked check (locked in ('Y', 'N'))
);
```

## table signon_audit

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `signon_audit`
- lines: 85-94

```sql
CREATE TABLE signon_audit (
  audit_id number(19) not null,
  username varchar2(25) not null,
  event_type varchar2(20) not null,
  event_ts timestamp not null,
  remote_addr varchar2(45),
  constraint pk_signon_audit primary key (audit_id),
  constraint ck_signon_audit_event check (event_type in
    ('SIGNON_OK', 'SIGNON_FAIL', 'SIGNON_LOCKED', 'ACCOUNT_LOCKED', 'SIGNOFF', 'USER_CREATED', 'ACCOUNT_UNLOCKED'))
);
```

## sequence signon_audit_seq

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `signon_audit_seq`
- lines: 96-96

```sql
CREATE SEQUENCE signon_audit_seq START WITH 1 INCREMENT BY 1 CACHE 20;
```

## trigger trg_signon_audit_id

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `trg_signon_audit_id`
- lines: 98-104
- touches: writes signon_audit

```sql
CREATE OR REPLACE TRIGGER trg_signon_audit_id
BEFORE INSERT ON signon_audit
FOR EACH ROW
WHEN (new.audit_id IS NULL)
BEGIN
  SELECT signon_audit_seq.NEXTVAL INTO :new.audit_id FROM dual;
END;
```

## view v_catalog_item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `v_catalog_item`
- lines: 112-120
- touches: reads item, reads item_details, reads product, reads product_details, reads category, reads category_details

```sql
CREATE VIEW v_catalog_item AS
SELECT d.catid, cd.name AS category_name, p.productid, pd.name AS product_name,
       i.itemid, idt.listprice, idt.unitcost, idt.attr1, idt.descn, idt.image, idt.locale
  FROM item i
  JOIN item_details idt ON idt.itemid = i.itemid
  JOIN product p ON p.productid = i.productid
  JOIN product_details pd ON pd.productid = p.productid AND pd.locale = idt.locale
  JOIN category d ON d.catid = p.catid
  JOIN category_details cd ON cd.catid = d.catid AND cd.locale = idt.locale;
```
