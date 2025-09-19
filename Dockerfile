# Stage 1: builder
FROM node:lts-alpine AS builder
WORKDIR /app

# Install only production dependencies first (better layer caching)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY . .

# Stage 2: runtime
FROM node:lts-alpine AS runtime
WORKDIR /app

# Copy only production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

# Drop dev dependencies to slim down image
RUN yarn install --frozen-lockfile --production --ignore-scripts --prefer-offline

# Set non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000
CMD ["node", "src/index.js"]
