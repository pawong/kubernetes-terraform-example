FROM python:3.12-slim
ARG GIT_HASH

# Update system packages to address vulnerabilities and remove unnecessary packages
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean
RUN pip3 install poetry

COPY ./ /backend/
WORKDIR /backend/

ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

ENV APP_USER=worker
ENV APP_GROUP=worker
ENV APP_UID=1001
ENV APP_GID=1001

RUN groupadd --gid "${APP_GID}" "${APP_GROUP}" \
    && useradd --uid "${APP_UID}" --gid "${APP_GROUP}" -m -s /bin/bash "${APP_USER}"

EXPOSE 81

USER ${APP_USER}

RUN poetry install --only main --no-root

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=20s \
    CMD curl -f http://localhost:81/health || exit 1

CMD ["poetry", "run", "uvicorn", "api.main:api", "--host", "0.0.0.0", "--port", "81"]
