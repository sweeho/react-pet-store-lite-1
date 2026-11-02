# Legacy runtime (SWHR5-N-0001)

`compose.yaml` starts the legacy application, Java Pet Store Lite, so the
acceptance suite can run against it.

|                              |                                                                                               |
| ---------------------------- | --------------------------------------------------------------------------------------------- |
| Application                  | Java Pet Store Lite, J2EE 1.3 (Servlet 2.3, JSP 1.2, JSTL 1.0)                                |
| Source                       | `legacy-source/j2ee-pet-store-lite/`                                                          |
| Build                        | The legacy code's own Maven build (`pom.xml` -> `petstore.war`), run by its own `Dockerfile`  |
| Application server           | Tomcat 9 on Java 8 (`tomcat:9.0-jdk8-temurin`)                                                |
| Database                     | Apache Derby 10.14, embedded in Tomcat (JNDI `jdbc/CatalogDB`). No separate database service. |
| URL for the acceptance suite | **`http://localhost:8080/petstore/`**                                                         |

## Start

Run from the repository root:

```sh
docker compose -f .vortex/legacy-runtime/compose.yaml up -d --build --wait
curl -fsS http://localhost:8080/petstore/ >/dev/null && echo up
```

`--wait` returns once the healthcheck sees `GET /petstore/` answer 200. The first
build downloads Maven dependencies and takes a few minutes.

Stop it and discard its database:

```sh
docker compose -f .vortex/legacy-runtime/compose.yaml down
```

The Derby database lives in the container (`/var/petstore/db`), so every
`up` after a `down` starts from an empty store.

## Data

The store starts empty. The legacy application loads its catalog and users itself
the first time someone opens `http://localhost:8080/petstore/` and follows
"enter the store" (`populating.jsp`, which calls the `/petstore/Populate` servlet). A suite that needs
catalog data or sign-on must do that first.

Accounts after population: `j2ee`/`j2ee` and `shopper`/`j2ee` (CUSTOMER),
`admin`/`admin` (ADMIN).

## What the container needs that is not in this repository

- **The legacy source at `legacy-source/j2ee-pet-store-lite/`.** It is on the
  spec-extraction branch (`vortex/legacy-spec/sx-0001`), not on `dev`. The
  build context in `compose.yaml` is `../../legacy-source/j2ee-pet-store-lite`
  relative to this file, so use a checkout that has that directory.
- **Network access during the build** to Docker Hub (`maven:3.9-eclipse-temurin-8`,
  `tomcat:9.0-jdk8-temurin`) and Maven Central (JSTL 1.0.6, taglibs standard 1.0.6,
  the Derby 10.14.2.0 jars).
- **No licence and no separate driver.** Tomcat, Derby and JSTL are open source.
  The Derby JDBC driver is fetched by the Maven build (`maven-dependency-plugin`
  copies it into Tomcat's `lib/`). The application code carries Sun's
  redistribution licence (`LICENSE-SUN.txt` in the source); it needs no key.
- **Host port 8080 free.** It does not clash with the new system (`:5000`) or
  its Playwright server (`:5178`).
