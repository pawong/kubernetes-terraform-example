FROM golang:1.22.2
ENV GIT_REVISION=$GIT_COMMIT

COPY ./ /backend/

WORKDIR /backend/
RUN echo "${GIT_REVISION}" >> REVISION

RUN go build -o main main.go

ENV HOST 0.0.0.0
ENV PORT 8080

CMD ["./main"]