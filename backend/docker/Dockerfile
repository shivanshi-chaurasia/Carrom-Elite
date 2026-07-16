FROM node:20-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ openssl

# Copy package files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Build TypeScript
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# ==========================================
FROM node:20-alpine AS runner

WORKDIR /app

RUN apk add --no-cache openssl tini

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built assets
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma

# Create logs directory
RUN mkdir -p logs && chown -R nodejs:nodejs logs

USER nodejs

EXPOSE 8080

ENV NODE_ENV=production \
    PORT=8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/server.js"]
