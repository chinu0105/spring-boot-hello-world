# ── Stage 1: Build ─────────────────────────────────────────────────
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven \
    && mvn clean package -DskipTests

# ── Stage 2: Runtime ───────────────────────────────────────────────
# Minimal JRE-only image — smaller, more secure than full JDK
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="chinmaya.mishra0105@gmail.com"
LABEL description="Spring Boot Hello World — Semtech DevOps Assignment"

WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "app.jar"]