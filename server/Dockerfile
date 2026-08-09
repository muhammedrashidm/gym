# =========================
# BUILD STAGE
# =========================
FROM node:22.12.0-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install ALL dependencies
# Required for NestJS build, TypeScript and Prisma CLI
RUN npm ci --quiet

# Copy Prisma files
COPY prisma ./prisma/
COPY prisma.config.ts ./

# Generate Prisma Client
RUN npx prisma generate

# Copy application source
COPY . .

# Build NestJS
RUN npm run build


# =========================
# PRODUCTION STAGE
# =========================
FROM node:22.12.0-alpine AS production

WORKDIR /usr/src/app

# Create non-root user
RUN addgroup -S nestjs && adduser -S nestjs -G nestjs

# Copy package files
COPY --from=builder /usr/src/app/package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev --quiet \
    && npm cache clean --force

# Copy compiled application
COPY --from=builder /usr/src/app/dist ./dist

# Copy Prisma schema/migrations/config
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/prisma.config.ts ./

# Copy generated Prisma client
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma

# Upload directory
RUN mkdir -p uploads

ENV NODE_ENV=production

RUN chown -R nestjs:nestjs /usr/src/app

USER nestjs

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/src/main.js"]