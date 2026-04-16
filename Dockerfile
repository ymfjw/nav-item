FROM node:20-alpine3.20 AS frontend-builder

WORKDIR /app

ARG CACHEBUST=1

COPY web/package*.json ./

# 安装依赖时禁用 npm 缓存即可
RUN npm install --no-cache && npm cache clean --force

COPY web/ ./

# 去掉 -- --no-cache 参数，只运行标准构建命令
RUN npm run build

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
