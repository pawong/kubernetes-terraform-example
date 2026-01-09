ARG VERSION=27-ea
ARG GRADLE_VERSION=ubi10
FROM gradle:${GRADLE_VERSION} AS build

COPY . /backend
WORKDIR /backend
RUN ./gradlew build --no-daemon

FROM openjdk:${VERSION}

COPY --from=BUILD /backend/build/libs/com.example.kotlin-example-all.jar /bin/runner/run.jar
WORKDIR /bin/runner

ARG GIT_HASH
ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

ENV APP_USER=worker
ENV APP_GROUP=worker
ENV APP_UID=1001
ENV APP_GID=1001

RUN groupadd --gid "${APP_GID}" "${APP_GROUP}" \
    && useradd --uid "${APP_UID}" --gid "${APP_GROUP}" -m -s /bin/bash "${APP_USER}"

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=20s \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

USER ${APP_USER}

CMD ["java","-jar","run.jar"]
