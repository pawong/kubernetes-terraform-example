ARG VERSION=21
FROM gradle:latest AS build

COPY . /backend
WORKDIR /backend
RUN ./gradlew build --no-daemon

FROM openjdk:${VERSION}

COPY --from=BUILD /backend/build/libs/com.example.kotlin-example-all.jar /bin/runner/run.jar
WORKDIR /bin/runner

ARG GIT_COMMIT
ENV GIT_COMMIT=${GIT_COMMIT}
RUN echo ${GIT_COMMIT} > REVISION

CMD ["java","-jar","run.jar"]
