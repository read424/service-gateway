# Stage 1: Build
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /build

COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

RUN chmod +x mvnw && \
    ./mvnw dependency:go-offline -B

COPY src src

RUN ./mvnw clean package -DskipTests -B

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /build/target/service-gateway-*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
