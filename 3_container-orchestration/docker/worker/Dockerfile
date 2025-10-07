FROM node:22-alpine AS deps
WORKDIR /app
RUN npm config set update-notifier false && npm set fund=false audit=false
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

FROM node:22-alpine
ENV NODE_ENV=production
WORKDIR /app
USER node
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node src ./src

CMD ["node","src/worker.js"]
