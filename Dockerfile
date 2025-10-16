# 基础镜像选择Node.js 18（适配项目依赖的Node版本要求）
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要工具并赋予权限
RUN apk add --no-cache bash && \
    chmod -R 777 /app

# 安装pnpm包管理器
RUN npm install -g pnpm && \
    chmod -R 777 /usr/local/lib/node_modules

# 复制项目根目录的依赖描述文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# 复制所有子包的package.json（确保workspace依赖解析正确）
COPY packages/webrtc/package.json packages/webrtc/
COPY packages/webrtc-im/package.json packages/webrtc-im/
COPY packages/websocket/package.json packages/websocket/

# 安装所有依赖（--frozen-lockfile确保依赖版本一致）
RUN pnpm install --frozen-lockfile && \
    chmod -R 777 node_modules && \
    chmod -R 777 packages

# 复制完整项目代码
COPY . .

# 赋予所有文件最高权限
RUN chmod -R 777 /app

# 构建所有子包
RUN pnpm -F @ft/webrtc run build && \
    pnpm -F @ft/webrtc-im run build && \
    pnpm -F @ft/websocket run build

# 生产环境镜像（精简体积）
FROM node:18-alpine

WORKDIR /app

# 安装必要工具并赋予权限
RUN apk add --no-cache bash && \
    npm install -g pnpm && \
    chmod -R 777 /usr/local/lib/node_modules && \
    chmod -R 777 /app

# 从构建阶段复制依赖和构建产物
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml

# 再次赋予所有文件最高权限
RUN chmod -R 777 /app

# 暴露服务端口（项目中明确使用3000端口）
EXPOSE 3000

# 启动命令（使用部署命令）
CMD ["pnpm", "run", "deploy:webrtc-im"]
