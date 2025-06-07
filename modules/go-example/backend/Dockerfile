FROM golang:1.22.2
ARG GIT_COMMIT

COPY ./ /backend/
WORKDIR /backend/

ENV GIT_COMMIT=${GIT_COMMIT}
RUN echo ${GIT_COMMIT} > REVISION

RUN go build -o main main.go

ENV HOST 0.0.0.0
ENV PORT 8080

CMD ["./main"]