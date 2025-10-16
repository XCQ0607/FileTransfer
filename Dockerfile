# 使用Node.js 18基础镜像
FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e

# 安装必要的系统工具（解决Alpine镜像可能的命令缺失问题）
RUN apk add --no-cache bash

# 设置工作目录
WORKDIR /app

# 安装符合要求的pnpm版本（>=8.11.0）
RUN npm install -g pnpm@8.15.6

# 复制monorepo结构的所有package.json（确保子包依赖被正确识别）
COPY package.json pnpm-lock.yaml ./
COPY packages/webrtc/package.json ./packages/webrtc/
COPY packages/webrtc-im/package.json ./packages/webrtc-im/
COPY packages/websocket/package.json ./packages/websocket/

# 安装所有依赖（包括开发依赖，因为构建需要rimraf等工具）
RUN pnpm install 

# 复制完整项目文件
COPY . .

# 暴露服务端口
EXPOSE 3000

# 启动命令
CMD ["npm", "run", "deploy:webrtc-im"]
