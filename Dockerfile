# Runtime only — JAR is built by GitHub Actions pipeline
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="chinmaya.mishra0105@gmail.com"
LABEL description="Spring Boot Hello World — Semtech DevOps Assignment"

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
