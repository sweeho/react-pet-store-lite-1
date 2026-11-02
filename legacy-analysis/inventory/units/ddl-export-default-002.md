# Unit ddl-export-default-002

Read through the DDL export adapter (ddl-export@1.0.0). 20 item(s). Cite each requirement with the trace kind, path and anchor given for its item.

## table product

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `product`
- lines: 23-28

```sql
CREATE TABLE product (
  productid char(10) not null,
  catid char(10) not null,
  constraint pk_product primary key (productid),
    constraint fk_product_1 foreign key (catid)
    references category (catid));
```

## table product_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `product_details`
- lines: 31-39

```sql
CREATE TABLE product_details (
  productid char(10) not null,
  locale char(10) not null,
  name varchar(80) not null,
  image varchar(255),
  descn varchar(255),
  constraint pk_product_details primary key (productid, locale),
    constraint fk_product_details_1 foreign key (productid)
    references product (productid));
```

## table item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `item`
- lines: 42-48

```sql
CREATE TABLE item (
  itemid char(10) not null,
  productid char(10) not null,
  constraint pk_item primary key (itemid),
    constraint fk_item_1 foreign key (productid)
    references product (productid)
);
```

## table item_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `item_details`
- lines: 51-67

```sql
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
```

## index idx_signon_audit_user_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `idx_signon_audit_user_ts`
- lines: 98-98
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_user_ts ON signon_audit (username, event_ts);
```

## table product

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `product`
- lines: 23-28

```sql
CREATE TABLE product (
  productid varchar(10) not null,
  catid varchar(10) not null,
  constraint pk_product primary key (productid),
    constraint fk_product_1 foreign key (catid)
    references category (catid));
```

## table product_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `product_details`
- lines: 31-39

```sql
CREATE TABLE product_details (
  productid varchar(10) not null,
  locale varchar(10) not null,
  name varchar2(80) not null,
  image varchar2(255),
  descn varchar2(255),
  constraint pk_product_details primary key (productid, locale),
    constraint fk_product_details_1 foreign key (productid)
    references product (productid));
```

## table item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `item`
- lines: 42-48

```sql
CREATE TABLE item (
  itemid varchar(10) not null,
  productid varchar(10) not null,
  constraint pk_item primary key (itemid),
    constraint fk_item_1 foreign key (productid)
    references product (productid)
);
```

## table item_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `item_details`
- lines: 51-67

```sql
CREATE TABLE item_details (
  itemid varchar(10) not null,
  listprice number(10,2) not null,
  unitcost number(10,2) not null,
  locale varchar(10) not null,
  image varchar2(255) not null,
  descn varchar2(255) not null,
  attr1 varchar2(80),
  attr2 varchar2(80),
  attr3 varchar2(80),
  attr4 varchar2(80),
  attr5 varchar2(80),
  constraint pk_item_details primary key (itemid, locale),
      constraint fk_item_details_1 foreign key (itemid)
      references item (itemid),
      constraint ck_item_details_price check (listprice >= unitcost)
);
```

## index idx_signon_audit_user_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `idx_signon_audit_user_ts`
- lines: 109-109
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_user_ts ON signon_audit (username, event_ts);
```

## table product

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `product`
- lines: 23-28

```sql
CREATE TABLE product (
  productid char(10) not null,
  catid char(10) not null,
  constraint pk_product primary key (productid),
    constraint fk_product_1 foreign key (catid)
    references category (catid));
```

## table product_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `product_details`
- lines: 31-39

```sql
CREATE TABLE product_details (
  productid char(10) not null,
  locale char(10) not null,
  name varchar(80) not null,
  image varchar(255),
  descn varchar(255),
  constraint pk_product_details primary key (productid, locale),
    constraint fk_product_details_1 foreign key (productid)
    references product (productid));
```

## table item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `item`
- lines: 42-48

```sql
CREATE TABLE item (
  itemid char(10) not null,
  productid char(10) not null,
  constraint pk_item primary key (itemid),
    constraint fk_item_1 foreign key (productid)
    references product (productid)
);
```

## table item_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `item_details`
- lines: 51-67

```sql
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
```

## index idx_signon_audit_user_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `idx_signon_audit_user_ts`
- lines: 98-98
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_user_ts ON signon_audit (username, event_ts);
```

## table product

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `product`
- lines: 23-28

```sql
CREATE TABLE product (
  productid varchar(10) not null,
  catid varchar(10) not null,
  constraint pk_product primary key (productid),
    constraint fk_product_1 foreign key (catid)
    references category (catid));
```

## table product_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `product_details`
- lines: 31-39

```sql
CREATE TABLE product_details (
  productid varchar(10) not null,
  locale varchar(10) not null,
  name varchar2(80) not null,
  image varchar2(255),
  descn varchar2(255),
  constraint pk_product_details primary key (productid, locale),
    constraint fk_product_details_1 foreign key (productid)
    references product (productid));
```

## table item

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `item`
- lines: 42-48

```sql
CREATE TABLE item (
  itemid varchar(10) not null,
  productid varchar(10) not null,
  constraint pk_item primary key (itemid),
    constraint fk_item_1 foreign key (productid)
    references product (productid)
);
```

## table item_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `item_details`
- lines: 51-67

```sql
CREATE TABLE item_details (
  itemid varchar(10) not null,
  listprice number(10,2) not null,
  unitcost number(10,2) not null,
  locale varchar(10) not null,
  image varchar2(255) not null,
  descn varchar2(255) not null,
  attr1 varchar2(80),
  attr2 varchar2(80),
  attr3 varchar2(80),
  attr4 varchar2(80),
  attr5 varchar2(80),
  constraint pk_item_details primary key (itemid, locale),
      constraint fk_item_details_1 foreign key (itemid)
      references item (itemid),
      constraint ck_item_details_price check (listprice >= unitcost)
);
```

## index idx_signon_audit_user_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `idx_signon_audit_user_ts`
- lines: 109-109
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_user_ts ON signon_audit (username, event_ts);
```
