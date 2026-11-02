# Java Pet Store Lite

A small, runnable J2EE 1.3 legacy application for testing and demonstrating
Vortex legacy modernisation (spec extraction). It is a reduced copy of Sun's
Java Pet Store Demo 1.3.2 (`petstore-1_3_2.zip`).

The original has 12 capabilities across 4 applications (petstore, admin, OPC,
supplier) and 20 components. Petstore Lite keeps 3:

| # | Capability | Kept from 1.3.2 | Changed |
|---|---|---|---|
| 1 | Catalog browsing and search | catalog component, Fast Lane Reader DAO, `CatalogDAOSQL.xml`, JSPs | Catalog EJB removed. English only. No cart links. |
| 2 | Sample data population | `PopulateServlet`, XML populators, `PopulateSQL.xml` | Customer/account populators removed. Users load by JDBC. Forced reload is ADMIN only. |
| 3 | Sign-on and access control | `SignOnFilter`, `signon-config.xml`, `CreateUserServlet` | SignOn/User EJBs replaced by `UserDAO`. Roles enforced. 3-strike lockout. Audit log. |

Removed: cart, checkout, orders, customer profile, OPC, supplier, admin
client, mailer, JMS, i18n (ja, zh), WAF event/EJB controller.

## Stack

Servlet 2.3, JSP 1.2, JSTL 1.0, JDBC with JNDI `jdbc/CatalogDB`, Apache Derby 10.14
(Cloudscape's successor). Runs on Tomcat 9 / Java 8. Package names stay
`com.sun.j2ee.blueprints.*`.

## Run

```sh
docker build -t petstore-lite .
docker run -d --name psl -p 8080:8080 petstore-lite
open http://localhost:8080/petstore/        # click "enter the store" to load data
```

Accounts: `j2ee`/`j2ee` and `shopper`/`j2ee` (CUSTOMER), `admin`/`admin` (ADMIN).

Load 90 days of sign-on history after the first load:

```sh
docker cp data/seed/signon_history.sql psl:/tmp/h.sql
docker exec psl sh -c '. /opt/petstore/conf/env.sh; psl_ij /tmp/h.sql'
```

Run a batch job: `docker exec psl /opt/petstore/batch/psl_acct_unlock.sh`

## Layout

| Path | Content |
|---|---|
| `src/main/java` | 42 Java classes: catalog, signon, populate, WAF template, encoding filter |
| `src/main/webapp` | 20 JSPs, `WEB-INF/web.xml`, `signon-config.xml`, screen definitions, populate XML, `CatalogDAOSQL.xml`, images |
| `db/schema` | DDL: `petstore_derby.sql` (runtime), `petstore_oracle.sql` (reference production, sequence and trigger) |
| `db/batch` | SQL run by the batch jobs |
| `batch` | 6 batch shell scripts |
| `scheduler/control-m/PSL_PETSTORE.xml` | Control-M DEFTABLE: 2 folders, 6 jobs |
| `conf` | `petstore.properties`, `env.sh` |
| `data/migration` | Full table extracts (CSV, with header) for migration testing |
| `data/interface` | Sample batch output file `signon_audit_YYYYMMDD.csv` |
| `data/seed` | Sign-on history SQL and its generator |
| `docs` | User Guide, Administrator Guide, Operations Runbook (PDF and HTML source), 16 screenshots |
| `vortex` | Vortex inputs, upload steps and the expected extraction |

## Vortex

See [vortex/README.md](vortex/README.md) for how to add each source, and
[vortex/expected-extraction.md](vortex/expected-extraction.md) for what a
correct extraction finds, including planted defects.

## License

Derived from Java Pet Store 1.3.2, Copyright 2002 Sun Microsystems, Inc.
See `LICENSE-SUN.txt`. Changes are marked `Petstore Lite:` in the source.
