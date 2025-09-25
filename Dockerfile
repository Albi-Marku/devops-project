# Stage 1: builder
FROM node:lts-alpine AS builder
WORKDIR /app

# Install only production dependencies first (better layer caching)
COPY package.json yarn.lock ./
RUN yarn install
# Copy source code
COPY . .

# Stage 2: runtime
FROM node:lts-alpine AS runtime
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy only production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

EXPOSE 3000
CMD ["node", "src/index.js"]