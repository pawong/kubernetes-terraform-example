FROM node:trixie-slim AS builder

COPY . /backend
WORKDIR /backend

RUN npm install

FROM node:trixie-slim

ARG GIT_HASH
ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

ENV NODE_ENV="production"

ENV APP_USER=worker
ENV APP_GROUP=worker
ENV APP_UID=1001
ENV APP_GID=1001

RUN addgroup ${APP_GROUP} && \
    adduser --ingroup ${APP_GROUP} --home /home/${APP_USER} ${APP_USER}

WORKDIR /backend
COPY --from=builder /backend /backend
RUN chown -R ${APP_USER}:${APP_GROUP} /backend

USER ${APP_USER}

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 3000

CMD ["npm", "start"]