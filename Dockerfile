# 基础镜像选择Node.js 18（适配项目依赖的Node版本要求）
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装pnpm包管理器
RUN npm install -g pnpm

# 复制项目根目录的依赖描述文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# 复制所有子包的package.json（确保workspace依赖解析正确）
COPY packages/webrtc-im/package.json packages/webrtc-im/
# 如需其他子包（如webrtc、websocket），补充对应复制命令
# COPY packages/webrtc/package.json packages/webrtc/
# COPY packages/websocket/package.json packages/websocket/

# 安装所有依赖（--frozen-lockfile确保依赖版本一致）
RUN pnpm install --frozen-lockfile

# 复制完整项目代码
COPY . .

# 构建所有子包（以webrtc-im为例，如需其他包补充构建命令）
RUN pnpm -F @ft/webrtc-im run build
# 如需构建其他包，添加对应命令
# RUN pnpm -F @ft/webrtc run build
# RUN pnpm -F @ft/websocket run build

# 生产环境镜像（精简体积）
FROM node:18-alpine

WORKDIR /app

# 安装pnpm（生产环境可能需要用于依赖管理）
RUN npm install -g pnpm

# 从构建阶段复制依赖和构建产物
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml

# 暴露服务端口（根据项目实际端口配置，默认推测为3000，可调整）
EXPOSE 3000

# 启动命令（根据README中的部署命令，可按需切换）
CMD ["pnpm", "run", "deploy:webrtc-im"]
