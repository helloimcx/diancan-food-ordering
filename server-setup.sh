#!/bin/bash

# 阿里云服务器Docker环境初始化脚本
# 请在阿里云服务器上以root权限运行此脚本

echo "🚀 开始配置阿里云服务器Docker环境..."

# 更新系统
echo "📦 更新系统包..."
yum update -y

# 安装Docker
echo "🐳 安装Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker

# 安装Docker Compose
echo "📦 安装Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 创建部署目录
echo "📁 创建部署目录..."
mkdir -p /opt/diancan-backend
mkdir -p /opt/diancan-backend/data
mkdir -p /opt/diancan-backend/logs

# 创建docker-compose.yml文件
echo "📝 创建Docker Compose配置..."
cat > /opt/diancan-backend/docker-compose.yml << 'EOF'
version: '3.8'

services:
  diancan-backend:
    image: ghcr.io/helloimcx/diancan-food-ordering:backend-latest
    container_name: diancan-backend
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    volumes:
      - ./data:/app
      - ./logs:/app/logs
    networks:
      - diancan-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/foods"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  diancan-network:
    driver: bridge

volumes:
  data:
  logs:
EOF

# 创建部署脚本
echo "📜 创建部署脚本..."
cat > /opt/diancan-backend/deploy.sh << 'EOF'
#!/bin/bash

# 部署脚本
set -e

echo "🚀 开始部署后端服务..."

# 拉取最新镜像
echo "📦 拉取最新Docker镜像..."
docker-compose pull diancan-backend

# 停止现有服务
echo "⏹️ 停止现有服务..."
docker-compose down

# 启动新服务
echo "🚀 启动新服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 健康检查
echo "🔍 执行健康检查..."
if curl -f http://localhost:3001/api/foods > /dev/null 2>&1; then
    echo "✅ 健康检查通过"
else
    echo "❌ 健康检查失败"
    echo "📋 查看容器日志："
    docker-compose logs diancan-backend
    exit 1
fi

echo "📊 查看容器状态："
docker-compose ps

echo "🎉 部署完成！"
echo "🌐 API地址: http://YOUR_SERVER_IP:3001"
EOF

chmod +x /opt/diancan-backend/deploy.sh

# 配置防火墙
echo "🔥 配置防火墙..."
firewall-cmd --permanent --add-port=3001/tcp
firewall-cmd --reload

# 配置防火墙（阿里云安全组）
echo "☁️ 阿里云安全组配置提示："
echo "请在阿里云控制台中为您的ECS实例安全组添加以下端口："
echo "- 3001 (TCP) - 后端API服务"
echo "- 22 (TCP) - SSH访问（如需要远程管理）"

# 创建日志清理脚本
echo "📜 创建日志清理脚本..."
cat > /opt/diancan-backend/cleanup.sh << 'EOF'
#!/bin/bash

# 日志清理脚本
echo "🧹 清理Docker资源..."

# 清理未使用的容器、网络、镜像
docker system prune -f

# 清理旧镜像
echo "📦 清理旧镜像..."
docker image prune -a -f

echo "✅ 清理完成"
EOF

chmod +x /opt/diancan-backend/cleanup.sh

# 创建服务管理脚本
echo "⚙️ 创建服务管理脚本..."
cat > /opt/diancan-backend/service-manager.sh << 'EOF'
#!/bin/bash

# 服务管理脚本
case "$1" in
  start)
    echo "🚀 启动服务..."
    docker-compose up -d
    ;;
  stop)
    echo "⏹️ 停止服务..."
    docker-compose down
    ;;
  restart)
    echo "🔄 重启服务..."
    docker-compose restart
    ;;
  logs)
    echo "📋 查看日志..."
    docker-compose logs -f diancan-backend
    ;;
  status)
    echo "📊 服务状态："
    docker-compose ps
    ;;
  update)
    echo "🔄 更新服务..."
    ./deploy.sh
    ;;
  *)
    echo "用法: $0 {start|stop|restart|logs|status|update}"
    exit 1
    ;;
esac
EOF

chmod +x /opt/diancan-backend/service-manager.sh

# 创建环境检查脚本
echo "🔍 创建环境检查脚本..."
cat > /opt/diancan-backend/health-check.sh << 'EOF'
#!/bin/bash

# 环境检查脚本
echo "🔍 检查部署环境..."

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装"
    exit 1
fi

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装"
    exit 1
fi

# 检查端口
if netstat -tlnp | grep :3001 > /dev/null; then
    echo "⚠️ 端口3001已被占用"
else
    echo "✅ 端口3001可用"
fi

# 检查容器状态
echo "📊 Docker容器状态："
docker ps -a | grep diancan-backend || echo "未找到diancan-backend容器"

# 检查API健康状态
if curl -f http://localhost:3001/api/foods > /dev/null 2>&1; then
    echo "✅ API健康检查通过"
else
    echo "❌ API健康检查失败"
fi

echo "✅ 环境检查完成"
EOF

chmod +x /opt/diancan-backend/health-check.sh

# 设置目录权限
echo "🔐 设置目录权限..."
chown -R $USER:$USER /opt/diancan-backend

echo ""
echo "🎉 阿里云服务器Docker环境配置完成！"
echo ""
echo "📋 下一步："
echo "1. 配置GitHub Secrets (ALICLOUD_HOST, ALICLOUD_USER, ALICLOUD_PRIVATE_KEY)"
echo "2. 推送代码到main分支触发自动部署"
echo "3. 手动运行一次部署：cd /opt/diancan-backend && ./deploy.sh"
echo ""
echo "🛠️ 常用命令："
echo "- 管理服务: cd /opt/diancan-backend && ./service-manager.sh [start|stop|restart|logs|status|update]"
echo "- 环境检查: cd /opt/diancan-backend && ./health-check.sh"
echo "- 清理资源: cd /opt/diancan-backend && ./cleanup.sh"
echo ""
echo "🌐 部署完成后API地址: http://YOUR_SERVER_IP:3001"