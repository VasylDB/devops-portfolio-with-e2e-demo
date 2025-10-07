# Simple Dockerfile for the demo app
FROM node:18-alpine

WORKDIR /app
COPY src/app/package*.json ./
RUN npm ci --only=production

COPY src/app ./

EXPOSE 3000
CMD ["npm", "start"]
