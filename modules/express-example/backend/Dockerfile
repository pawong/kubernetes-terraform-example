FROM node:18-alpine as builder
ARG GIT_HASH
ENV NODE_ENV="production"

COPY . /backend
WORKDIR /backend

RUN npm install
FROM node:18-alpine

ENV NODE_ENV="production"
ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

COPY --from=builder /backend /backend

WORKDIR /backend
EXPOSE 3000

CMD ["npm", "start"]