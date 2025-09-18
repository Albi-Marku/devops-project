# Stage 1: builder
FROM node:lts-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .

# Stage 2: runtime
FROM node:lts-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["node", "src/index.js"]
