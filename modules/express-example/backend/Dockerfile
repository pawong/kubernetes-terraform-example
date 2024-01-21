FROM node:18-alpine as builder
ENV NODE_ENV="production"

COPY . /backend
WORKDIR /backend

RUN npm install
FROM node:18-alpine

ENV NODE_ENV="production"
COPY --from=builder /backend /backend

WORKDIR /backend
EXPOSE 3000

CMD ["npm", "start"]