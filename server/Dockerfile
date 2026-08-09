# ==== BUILD STAGE ====
FROM node:22.12.0-alpine AS builder

WORKDIR /usr/src/app

# Dependency manifests first, so npm ci is cached independently of source changes
COPY package*.json ./

# Prisma schema + config are needed by `prisma generate`
COPY prisma ./prisma/
COPY prisma.config.ts ./

# Install deps (including devDeps: prisma CLI + nest CLI are needed to build)
RUN npm ci --quiet

# Generate Prisma Client into node_modules/.prisma/client (standard location)
RUN npx prisma generate

# Copy the rest of the source
COPY . .

# Build NestJS app -> ./dist (entry is dist/src/main.js)
RUN npm run build


# ==== PRODUCTION STAGE ====
FROM node:22.12.0-alpine AS production

WORKDIR /usr/src/app

# Create non-root user
RUN addgroup -S nestjs && adduser -S nestjs -G nestjs

COPY --from=builder /usr/src/app/package*.json ./

# Install runtime deps. devDeps are kept because `prisma migrate deploy` runs at
# container start and the prisma CLI (plus TypeScript, for prisma.config.ts) is a
# devDependency. npm cache is dropped to keep the layer small.
RUN npm ci --omit=dev --quiet && npm cache clean --force

# Compiled application
COPY --from=builder /usr/src/app/dist ./dist

# Schema + migrations + config, required by `prisma migrate deploy`
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/prisma.config.ts ./

# The generated Prisma Client. `npm ci` above installs the @prisma/client package
# but not the generated client, which lives in node_modules/.prisma/client — so it
# must be copied AFTER npm ci or it would be wiped.
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma

# Static uploads dir referenced by main.ts (dist/../uploads at runtime)
RUN mkdir -p uploads

ENV NODE_ENV=production

RUN chown -R nestjs:nestjs /usr/src/app
USER nestjs

EXPOSE 3000

# Apply migrations THEN start the app
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/src/main.js"]
