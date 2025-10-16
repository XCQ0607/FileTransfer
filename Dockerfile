# 使用Node.js 18基础镜像
FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e

# 设置工作目录
WORKDIR /app

# 安装与锁文件兼容的pnpm版本（锁定版本避免兼容性问题）
RUN npm install -g pnpm@7.30.5

# 复制所有package.json和锁文件（项目为monorepo结构，需包含子包配置）
COPY package.json pnpm-lock.yaml ./
COPY packages/webrtc/package.json ./packages/webrtc/
COPY packages/webrtc-im/package.json ./packages/webrtc-im/
COPY packages/websocket/package.json ./packages/websocket/

# 安装依赖（使用--force解决锁文件版本兼容问题，或确保pnpm版本匹配）
RUN pnpm install --frozen-lockfile

# 复制完整项目文件
COPY . .

# 暴露服务端口
EXPOSE 3000

# 启动命令
CMD ["npm", "run", "deploy:webrtc-im"]
