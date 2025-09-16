FROM golang:1.25.1-alpine AS builder

WORKDIR /backend

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o api api/api.go

FROM alpine:3.20

ARG GIT_HASH
ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

ENV APP_USER=worker
ENV APP_GROUP=worker
ENV APP_UID=1000
ENV APP_GID=1000

RUN addgroup -g ${APP_GID} ${APP_GROUP} \
    && adduser -u ${APP_UID} -G ${APP_GROUP} -S ${APP_USER}

RUN apk update && apk add curl

ENV HOST=0.0.0.0
ENV PORT=8080

WORKDIR /backend
COPY --from=builder /backend/api/api .
RUN chown -R ${APP_USER}:${APP_GROUP} /backend

USER ${APP_USER}

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 8080

CMD ["./api"]
