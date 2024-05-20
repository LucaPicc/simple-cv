FROM node:20-alpine3.19 AS base

WORKDIR /app

COPY ./src/package.json ./src/package-lock.json ./
RUN npm ci

FROM base AS builder

WORKDIR /app
COPY --from=base /app/node_modules ./node_modules
COPY ./src .

RUN npm run build

FROM builder as runner
ARG PORT

COPY --from=base /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=${PORT}

EXPOSE $PORT

CMD node ./dist/server/entry.mjs
