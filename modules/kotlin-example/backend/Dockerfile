ARG VERSION=27-ea
FROM gradle:latest AS build

COPY . /backend
WORKDIR /backend
RUN ./gradlew build --no-daemon

FROM openjdk:${VERSION}

COPY --from=BUILD /backend/build/libs/com.example.kotlin-example-all.jar /bin/runner/run.jar
WORKDIR /bin/runner

ARG GIT_HASH
ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=20s \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["java","-jar","run.jar"]
