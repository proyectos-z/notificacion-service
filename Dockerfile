# syntax=docker/dockerfile:1
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /workspace

COPY pom.xml .
COPY envio-service/pom.xml envio-service/
COPY tarifa-service/pom.xml tarifa-service/
COPY notificacion-service/pom.xml notificacion-service/

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B dependency:resolve -pl notificacion-service -am -q

COPY notificacion-service/src notificacion-service/src

RUN --mount=type=cache,target=/root/.m2 \
    mvn -B package -pl notificacion-service -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /workspace/notificacion-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
