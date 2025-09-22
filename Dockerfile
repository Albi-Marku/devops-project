# Simple production Dockerfile
FROM node:lts-alpine

WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copy source
COPY . .

# Create a writable data folder for SQLite
RUN mkdir -p /app/data && chown -R node:node /app

USER node

EXPOSE 3000
CMD ["node", "src/index.js"]
