FROM node:20-alpine3.20 AS frontend-builder

WORKDIR /app

# 添加一个可变的构建参数，用于强制破坏 Docker 缓存
ARG CACHEBUST=1

COPY web/package*.json ./

# 安装依赖时禁用缓存，并清理 npm 缓存
RUN npm install --no-cache && npm cache clean --force

COPY web/ ./

# 构建时也禁用缓存
RUN npm run build -- --no-cache

# 生产环境
FROM node:20-alpine3.20 AS production

RUN apk add --no-cache \
    sqlite \
    && rm -rf /var/cache/apk/*

WORKDIR /app

RUN mkdir -p uploads database web/dist

COPY package*.json ./

RUN npm install

COPY app.js config.js db.js ./
COPY routes/ ./routes/

COPY --from=frontend-builder /app/dist ./web/dist

ENV NODE_ENV=production

EXPOSE 3000/tcp

CMD ["npm", "start"] 
