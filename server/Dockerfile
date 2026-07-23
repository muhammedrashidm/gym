# ==== BUILD STAGE ====
FROM node:22.12.0-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./
COPY prisma ./prisma/
COPY prisma.config.ts ./

# Install deps (including devDeps for prisma + nest build)
RUN npm ci --quiet

# Generate Prisma Client (emits to ./generated/prisma per schema config)
RUN npx prisma generate

# Copy source
COPY . .

# Build NestJS app -> ./dist (includes dist/src and dist/generated/prisma)
RUN npm run build


# ==== PRODUCTION STAGE ====
FROM node:22.12.0-alpine AS production

WORKDIR /usr/src/app

# Create non-root user
RUN addgroup -S nestjs && adduser -S nestjs -G nestjs

# Copy package files
COPY --from=builder /usr/src/app/package*.json ./

# Install ALL deps (Prisma CLI is a devDependency, needed for `migrate deploy`)
RUN npm ci --quiet

# Copy build output & prisma artifacts.
# The generated Prisma client is compiled into dist/generated/prisma, so no
# separate node_modules/.prisma copy is needed (driver-adapter based client).
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/prisma.config.ts ./

# Static uploads dir referenced by main.ts (dist/../uploads at runtime)
RUN mkdir -p uploads

# Set environment
ENV NODE_ENV=production

# Ownership & user
RUN chown -R nestjs:nestjs /usr/src/app
USER nestjs

EXPOSE 3000

# Apply migrations THEN start app (entry is dist/src/main.js for this project)
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/src/main.js"]
