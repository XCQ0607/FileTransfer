# 基础镜像选择Node.js 18
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要工具并赋予权限
RUN apk add --no-cache bash && \
    chmod -R 777 /app

# 安装pnpm包管理器
RUN npm install -g pnpm && \
    chmod -R 777 /usr/local/lib/node_modules

# 复制项目根目录的关键配置文件（新增 tsconfig.json）
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.json ./

# 复制所有子包的package.json
COPY packages/webrtc/package.json packages/webrtc/
COPY packages/webrtc-im/package.json packages/webrtc-im/
COPY packages/websocket/package.json packages/websocket/

# 安装所有依赖
RUN pnpm install --frozen-lockfile && \
    chmod -R 777 node_modules && \
    chmod -R 777 packages

# 复制完整项目代码（确保所有文件被包含，包括子包的配置）
COPY . .

# 赋予所有文件权限
RUN chmod -R 777 /app

# 构建所有子包
RUN pnpm -F @ft/webrtc run build && \
    pnpm -F @ft/webrtc-im run build && \
    pnpm -F @ft/websocket run build

# 生产环境镜像
FROM node:18-alpine

WORKDIR /app

# 安装必要工具并赋予权限
RUN apk add --no-cache bash && \
    npm install -g pnpm && \
    chmod -R 777 /usr/local/lib/node_modules && \
    chmod -R 777 /app

# 从构建阶段复制依赖、产物和配置文件（包括 tsconfig.json）
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --from=builder /app/tsconfig.json ./tsconfig.json  # 新增复制根目录tsconfig

# 再次赋予权限
RUN chmod -R 777 /app

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["pnpm", "run", "deploy:webrtc-im"]
