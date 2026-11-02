# Petstore Lite runtime: Tomcat 9 on Java 8 with an embedded Derby database.
# Build:  docker build -t petstore-lite .
# Run:    docker run -p 8080:8080 petstore-lite   then open http://localhost:8080/petstore/

FROM maven:3.9-eclipse-temurin-8 AS war
WORKDIR /src
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B package

FROM tomcat:9.0-jdk8-temurin
RUN rm -rf /usr/local/tomcat/webapps/* \
 && sed -i 's/^tomcat.util.scan.StandardJarScanFilter.jarsToSkip=/&derby*.jar,/' /usr/local/tomcat/conf/catalina.properties \
 && mkdir -p /var/petstore/db /var/petstore/backup /var/petstore/extract /var/petstore/log
COPY --from=war /src/target/container-lib/*.jar /usr/local/tomcat/lib/
COPY --from=war /src/target/petstore.war /usr/local/tomcat/webapps/petstore.war
COPY conf/ /opt/petstore/conf/
COPY batch/ /opt/petstore/batch/
COPY db/ /opt/petstore/db/
RUN chmod +x /opt/petstore/batch/*.sh
# Derby runs embedded in Tomcat and also listens on 1527 so the batch jobs can connect
ENV CATALINA_OPTS="-Dderby.system.home=/var/petstore/db -Dderby.drda.startNetworkServer=true -Dderby.drda.host=0.0.0.0 -Dderby.drda.portNumber=1527"
EXPOSE 8080 1527
