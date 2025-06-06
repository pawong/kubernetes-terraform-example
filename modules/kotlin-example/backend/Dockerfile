ARG VERSION=21
FROM gradle:latest AS build

COPY . /backend
WORKDIR /backend
RUN ./gradlew build --no-daemon

FROM openjdk:${VERSION}

COPY --from=BUILD /backend/build/libs/com.example.kotlin-example-all.jar /bin/runner/run.jar
WORKDIR /bin/runner

CMD ["java","-jar","run.jar"]
