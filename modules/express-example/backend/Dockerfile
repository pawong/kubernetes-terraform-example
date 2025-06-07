FROM node:18-alpine as builder
ARG GIT_COMMIT
ENV NODE_ENV="production"

COPY . /backend
WORKDIR /backend

RUN npm install
FROM node:18-alpine

ENV NODE_ENV="production"
ENV GIT_COMMIT=${GIT_COMMIT}
RUN echo ${GIT_COMMIT} > REVISION

COPY --from=builder /backend /backend

WORKDIR /backend
EXPOSE 3000

CMD ["npm", "start"]