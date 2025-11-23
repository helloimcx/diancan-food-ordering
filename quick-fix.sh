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
