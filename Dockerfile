# Stage 1: builder
FROM node:lts-alpine AS builder
WORKDIR /app

# Install all deps (including dev, needed for build)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY . .

# Stage 2: runtime
FROM node:lts-alpine AS runtime
WORKDIR /app

# Copy only package files first
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./

# Install *production* deps directly in runtime (ensures sqlite3 compiles here)
RUN yarn install --frozen-lockfile --production

# Copy app source (but NOT node_modules from builder)
COPY --from=builder /app/src ./src

# Security: drop root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000
CMD ["node", "src/index.js"]
