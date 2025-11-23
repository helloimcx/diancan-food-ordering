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
