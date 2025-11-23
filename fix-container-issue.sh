#!/bin/bash

# Docker容器启动失败修复脚本
# 解决容器内找不到package.json的问题

echo "🔧 修复Docker容器启动失败问题..."

# 检查server目录内容
echo "📋 检查server目录内容..."
echo "当前server目录文件："
ls -la server/

echo ""
echo "📄 检查package.json内容："
cat server/package.json

echo ""
echo "🔧 创建改进的Dockerfile..."

# 创建改进的Dockerfile
cat > server/Dockerfile.new << 'EOF'
# 改进的后端Dockerfile - 家庭点餐系统
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 创建app用户（安全最佳实践）
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

# 复制package.json和package-lock.json
COPY package*.json ./

# 验证package.json是否存在
RUN if [ ! -f package.json ]; then echo "❌ package.json not found!"; exit 1; fi

# 安装依赖
RUN npm install --production

# 验证npm install是否成功
RUN ls -la node_modules/ && echo "✅ Dependencies installed"

# 复制应用代码
COPY . .

# 验证关键文件存在
RUN echo "🔍 验证关键文件:" && \
    if [ -f server.js ]; then echo "✅ server.js exists"; else echo "❌ server.js missing"; fi && \
    if [ -f database.js ]; then echo "✅ database.js exists"; else echo "❌ database.js missing"; fi && \
    if [ -f package.json ]; then echo "✅ package.json exists"; else echo "❌ package.json missing"; fi

# 创建必要的目录
RUN mkdir -p uploads && \
    chown -R nodeuser:nodejs /app

# 暴露端口
EXPOSE 3001

# 切换到nodeuser用户
USER nodeuser

# 健康检查（使用node而不是curl）
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/foods', (res) => {process.exit(res.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"

# 启动应用
CMD ["npm", "start"]
EOF

echo "✅ 创建了改进的Dockerfile.new"

# 创建调试Docker镜像的脚本
cat > debug-docker.sh << 'EOF'
#!/bin/bash

echo "🔍 调试Docker镜像问题..."

echo "📋 1. 检查当前Docker镜像内容..."
docker exec diancan-backend ls -la /app/
docker exec diancan-backend ls -la /app/package.json 2>/dev/null || echo "❌ package.json不存在"

echo ""
echo "📋 2. 检查Docker镜像基本信息..."
docker image inspect ghcr.io/helloimcx/diancan-food-ordering:backend-latest

echo ""
echo "📋 3. 重新构建镜像..."
docker build -t ghcr.io/helloimcx/diancan-food-ordering:debug ./server

echo ""
echo "📋 4. 运行调试容器..."
docker stop diancan-backend || true
docker rm diancan-backend || true

docker run -d \
  --name diancan-debug \
  -p 3002:3001 \
  ghcr.io/helloimcx/diancan-food-ordering:debug

echo ""
echo "📋 5. 检查调试容器状态..."
docker logs diancan-debug
docker ps --filter name=diancan-debug

echo ""
echo "📋 6. 进入容器调试..."
echo "执行: docker exec -it diancan-debug sh"
EOF

chmod +x debug-docker.sh

# 创建快速修复脚本
cat > quick-fix.sh << 'EOF'
#!/bin/bash

echo "🚀 快速修复Docker容器..."

# 停止并删除问题容器
echo "🛑 停止问题容器..."
docker stop diancan-backend || true
docker rm diancan-backend || true

# 重新构建镜像
echo "🔨 重新构建镜像..."
docker build -t ghcr.io/helloimcx/diancan-food-ordering:backend-latest ./server

# 验证镜像构建成功
if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功"
else
    echo "❌ 镜像构建失败"
    exit 1
fi

# 启动新容器
echo "🚀 启动新容器..."
docker run -d \
  --name diancan-backend \
  --restart unless-stopped \
  -p 3001:3001 \
  -e NODE_ENV=production \
  -v /opt/diancan-backend/data:/app \
  ghcr.io/helloimcx/diancan-food-ordering:backend-latest

# 等待启动
echo "⏳ 等待服务启动..."
sleep 15

# 验证容器状态
echo "✅ 验证部署状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 健康检查
if curl -f http://localhost:3001/api/foods >/dev/null 2>&1; then
    echo "🎉 健康检查通过，服务正常运行！"
else
    echo "⚠️ 健康检查失败，检查日志:"
    docker logs diancan-backend --tail 20
fi
EOF

chmod +x quick-fix.sh

echo ""
echo "🔧 修复工具已创建完成！"
echo ""
echo "📋 可用的修复选项："
echo ""
echo "1. 🚀 快速修复（推荐）:"
echo "   ./quick-fix.sh"
echo ""
echo "2. 🔍 详细调试:"
echo "   ./debug-docker.sh"
echo ""
echo "3. 📖 手动检查:"
echo "   docker exec diancan-backend ls -la /app/"
echo ""
echo "4. 🔄 应用新的Dockerfile:"
echo "   cd server && mv Dockerfile Dockerfile.backup && mv Dockerfile.new Dockerfile"
echo ""
echo "💡 建议先运行快速修复，如果仍有问题再用调试模式检查"