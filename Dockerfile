FROM node:alpine AS builder
WORKDIR /app
COPY . .
# (1) yarn installは不要。buildだけ
RUN yarn build

FROM node:alpine AS runner
WORKDIR /app

ENV NODE_ENV production

# (2) Yarn 2を有効化
COPY --from=builder /app/.yarnrc.yml ./.yarnrc.yml
COPY --from=builder /app/.yarn ./.yarn
# (3) PnPのために必要なファイル
COPY --from=builder /app/.pnp.js ./.pnp.js
COPY --from=builder /app/yarn.lock ./yarn.lock

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
RUN chown -R nextjs:nodejs /app/.next
USER nextjs

EXPOSE 3000

CMD ["yarn", "start"]
