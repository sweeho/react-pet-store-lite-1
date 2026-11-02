# Unit ddl-export-default-001

Read through the DDL export adapter (ddl-export@1.0.0). 20 item(s). Cite each requirement with the trace kind, path and anchor given for its item.

## table category

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `category`
- lines: 11-12

```sql
CREATE TABLE category (catid char(10) not null,
  constraint pk_category primary key (catid));
```

## table category_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `category_details`
- lines: 15-20

```sql
CREATE TABLE category_details (catid char(10) not null,
  name varchar(80) not null, image varchar(255),
  descn varchar(255), locale char(10) not null,
  constraint pk_category_details primary key (catid, locale),
    constraint fk_category_details_1 foreign key (catid)
    references category (catid));
```

## index idx_product_catid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `idx_product_catid`
- lines: 96-96
- touches: reads product

```sql
CREATE INDEX idx_product_catid ON product (catid);
```

## index idx_item_productid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `idx_item_productid`
- lines: 97-97
- touches: reads item

```sql
CREATE INDEX idx_item_productid ON item (productid);
```

## index idx_signon_audit_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_derby.sql`
- anchor: `idx_signon_audit_ts`
- lines: 99-99
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_ts ON signon_audit (event_ts);
```

## table category

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `category`
- lines: 11-12

```sql
CREATE TABLE category (catid varchar(10) not null,
  constraint pk_category primary key (catid));
```

## table category_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `category_details`
- lines: 15-20

```sql
CREATE TABLE category_details (catid varchar(10) not null,
  name varchar2(80) not null, image varchar2(255),
  descn varchar2(255), locale varchar(10) not null,
  constraint pk_category_details primary key (catid, locale),
    constraint fk_category_details_1 foreign key (catid)
    references category (catid));
```

## index idx_product_catid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `idx_product_catid`
- lines: 107-107
- touches: reads product

```sql
CREATE INDEX idx_product_catid ON product (catid);
```

## index idx_item_productid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `idx_item_productid`
- lines: 108-108
- touches: reads item

```sql
CREATE INDEX idx_item_productid ON item (productid);
```

## index idx_signon_audit_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/db/schema/petstore_oracle.sql`
- anchor: `idx_signon_audit_ts`
- lines: 110-110
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_ts ON signon_audit (event_ts);
```

## table category

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `category`
- lines: 11-12

```sql
CREATE TABLE category (catid char(10) not null,
  constraint pk_category primary key (catid));
```

## table category_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `category_details`
- lines: 15-20

```sql
CREATE TABLE category_details (catid char(10) not null,
  name varchar(80) not null, image varchar(255),
  descn varchar(255), locale char(10) not null,
  constraint pk_category_details primary key (catid, locale),
    constraint fk_category_details_1 foreign key (catid)
    references category (catid));
```

## index idx_product_catid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `idx_product_catid`
- lines: 96-96
- touches: reads product

```sql
CREATE INDEX idx_product_catid ON product (catid);
```

## index idx_item_productid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `idx_item_productid`
- lines: 97-97
- touches: reads item

```sql
CREATE INDEX idx_item_productid ON item (productid);
```

## index idx_signon_audit_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_derby.sql`
- anchor: `idx_signon_audit_ts`
- lines: 99-99
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_ts ON signon_audit (event_ts);
```

## table category

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `category`
- lines: 11-12

```sql
CREATE TABLE category (catid varchar(10) not null,
  constraint pk_category primary key (catid));
```

## table category_details

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `category_details`
- lines: 15-20

```sql
CREATE TABLE category_details (catid varchar(10) not null,
  name varchar2(80) not null, image varchar2(255),
  descn varchar2(255), locale varchar(10) not null,
  constraint pk_category_details primary key (catid, locale),
    constraint fk_category_details_1 foreign key (catid)
    references category (catid));
```

## index idx_product_catid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `idx_product_catid`
- lines: 107-107
- touches: reads product

```sql
CREATE INDEX idx_product_catid ON product (catid);
```

## index idx_item_productid

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `idx_item_productid`
- lines: 108-108
- touches: reads item

```sql
CREATE INDEX idx_item_productid ON item (productid);
```

## index idx_signon_audit_ts

- trace kind: `db_object`
- path: `j2ee-pet-store-lite/vortex/inputs/02-database/petstore_oracle.sql`
- anchor: `idx_signon_audit_ts`
- lines: 110-110
- touches: reads signon_audit

```sql
CREATE INDEX idx_signon_audit_ts ON signon_audit (event_ts);
```
