# Spring Boot Hello World API

This is a small Spring-Boot Hello World application to demonstrate a quick and simple API.

It has one endpoint which returns a JSON response containing the hostname and IP of the server and an obligatory hello world message. 

## Requirements
 * Java 1.8
 * Maven
 
## Using the API
Simply start the app and make a HTTP GET request to http://localhost:8080/ and you will get a JSON response.

## Docker Build
The application has been built and packaged in a Docker container and published to DockerHub: https://hub.docker.com/r/kimb88/hello-world-spring-boot/

## How To

#### Clean and Build
```
mvn clean package
```

#### Run
```
mvn spring-boot:run
open http://localhost:8080/
```
Or
```
java -jar ./target/spring-boot-hello-world-1.0.0-SNAPSHOT.jar
```

#### Test
```
mvn verify
```

#### Docker Build
```
mvn package docker:build
```
Or

```
mvn package docker:build -Dmaven.test.skip=true
```

#### Docker Push
```
docker login
docker tag hello-world-spring-boot kimb88/hello-world-spring-boot
docker push kimb88/hello-world-spring-boot
```

## GitHub Actions Docker Workflow
This repository includes a CI/CD workflow defined in `.github/workflows/docker.yml`.

- Triggers on `push` to `main`, `master`, and `feature/**` branches, plus `pull_request` events targeting `main` and `master`.
- Job `build` compiles the app with Maven, packages the JAR, and uploads it as an artifact.
- Job `docker` runs after `build`, downloads the packaged JAR, builds a Docker image, and pushes it to DockerHub.
- Docker tags are generated automatically:
  - `latest` and a short commit SHA tag for `main`/`master`
  - `branch-short-sha` for feature branches
- Requires GitHub secrets:
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`

The workflow uses the image name `hello-spring` from the `IMAGE_NAME` environment variable and publishes images to DockerHub under the configured DockerHub username.

