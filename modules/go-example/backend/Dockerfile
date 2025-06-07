FROM golang:1.22.2
ARG GIT_HASH

COPY ./ /backend/
WORKDIR /backend/

ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

RUN go build -o main main.go

ENV HOST=0.0.0.0
ENV PORT=8080

CMD ["./main"]