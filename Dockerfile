# 使用Node.js 18基础镜像（兼容项目依赖的Node版本要求）
FROM node:18-alpine AS base

# 设置工作目录
WORKDIR /app

# 安装pnpm包管理器
RUN npm install -g pnpm

# 复制项目依赖配置文件
COPY package.json pnpm-lock.yaml ./

# 安装项目依赖（使用冻结锁文件确保依赖一致性）
RUN pnpm install --frozen-lockfile

# 复制项目所有文件
COPY . .

# 暴露服务端口（webrtc-im默认3000，其他服务需修改对应端口）
EXPOSE 3000

# 启动命令：部署webrtc-im服务（对应根目录package.json中的deploy:webrtc-im脚本）
# 该命令会执行子包的构建和启动流程：build -> node build/server.js
CMD ["npm", "run", "deploy:webrtc-im"]
