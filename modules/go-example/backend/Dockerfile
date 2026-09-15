FROM golang:1.26.0-alpine AS builder

WORKDIR /backend

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o api api/api.go


FROM alpine:3.20

ARG GIT_HASH
ENV GIT_HASH=${GIT_HASH}

RUN echo "${GIT_HASH}" > /REVISION

ENV APP_USER=worker \
    APP_GROUP=worker \
    APP_UID=1000 \
    APP_GID=1000

RUN addgroup -g ${APP_GID} ${APP_GROUP} \
    && adduser -u ${APP_UID} -G ${APP_GROUP} -S ${APP_USER}

RUN apk add --no-cache curl

ENV HOST=0.0.0.0 \
    PORT=8080

WORKDIR /backend

# Application binary
COPY --from=builder /backend/api/api ./api

# Documentation
COPY --from=builder /backend/docs ./docs

RUN chown -R ${APP_USER}:${APP_GROUP} /backend

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

USER ${APP_USER}

CMD ["./api"]
