#!/bin/bash

# Docker镜像部署问题修复脚本
# 解决镜像找不到和SSH认证问题

echo "🔧 修复Docker部署问题..."

# 检查GitHub Actions工作流
echo "📋 检查当前工作流配置..."
if [ -f ".github/workflows/deploy-alicloud.yml" ]; then
    echo "✅ 发现GitHub Actions工作流"
else
    echo "❌ 未找到GitHub Actions工作流"
    exit 1
fi

# 生成新的简化部署工作流
cat > .github/workflows/simple-deploy.yml << 'EOF'
name: 简化部署到阿里云

on:
  push:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
    - name: 检出代码
      uses: actions/checkout@v4

    - name: 设置Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'

    - name: 设置Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: 登录GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: 构建和推送Docker镜像
      uses: docker/build-push-action@v6
      with:
        context: ./server
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:backend-latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: 验证镜像推送
      run: |
        echo "🔍 验证镜像推送..."
        
        # 等待镜像同步
        sleep 30
        
        # 验证镜像存在
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
          -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
          "https://ghcr.io/v2/helloimcx/diancan-food-ordering/manifests/backend-latest")
        
        if [ "$RESPONSE" = "200" ]; then
          echo "✅ 镜像推送成功: backend-latest"
        else
          echo "❌ 镜像推送失败，状态码: $RESPONSE"
          echo "📋 可用标签列表:"
          curl -s -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            "https://ghcr.io/v2/helloimcx/diancan-food-ordering/tags/list" | jq '.'
          exit 1
        fi

    - name: 服务器部署（需要SSH配置）
      if: env.ALICLOUD_HOST != ''
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.ALICLOUD_HOST }}
        username: ${{ secrets.ALICLOUD_USER || 'root' }}
        key: ${{ secrets.ALICLOUD_PRIVATE_KEY }}
        port: ${{ secrets.ALICLOUD_PORT || 22 }}
        timeout: 30000
        script: |
          echo "🔄 开始服务器部署..."
          
          # 检查Docker是否可用
          if ! command -v docker &> /dev/null; then
            echo "❌ Docker未安装，尝试安装..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            systemctl start docker
          fi
          
          # 检查镜像是否存在
          echo "🔍 检查Docker镜像..."
          docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:backend-latest || {
            echo "❌ 镜像拉取失败，尝试latest标签..."
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          }
          
          # 停止并删除现有容器
          echo "🛑 停止现有容器..."
          docker stop diancan-backend || true
          docker rm diancan-backend || true
          
          # 启动新容器
          echo "🚀 启动新容器..."
          docker run -d \
            --name diancan-backend \
            --restart unless-stopped \
            -p 3001:3001 \
            -e NODE_ENV=production \
            -v /opt/diancan-backend/data:/app \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:backend-latest || \
          docker run -d \
            --name diancan-backend \
            --restart unless-stopped \
            -p 3001:3001 \
            -e NODE_ENV=production \
            -v /opt/diancan-backend/data:/app \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          
          # 等待服务启动
          echo "⏳ 等待服务启动..."
          sleep 15
          
          # 验证部署
          echo "✅ 验证部署状态..."
          docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
          
          # 健康检查
          if curl -f http://localhost:3001/api/foods; then
            echo "✅ 服务健康检查通过"
          else
            echo "⚠️ 健康检查失败，检查日志:"
            docker logs diancan-backend --tail 20
            exit 1
          fi
          
          echo "🎉 部署完成！"
EOF

echo "✅ 创建了简化部署工作流"

# 创建Docker镜像验证脚本
cat > verify-image.sh << 'EOF'
#!/bin/bash

echo "🔍 验证Docker镜像..."

# 检查镜像是否存在
echo "检查镜像: ghcr.io/helloimcx/diancan-food-ordering:backend-latest"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/helloimcx/diancan-food-ordering/manifests/backend-latest"

echo ""
echo "获取所有可用标签:"
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/helloimcx/diancan-food-ordering/tags/list" | jq '.'
EOF

chmod +x verify-image.sh

echo ""
echo "📋 问题修复完成！"
echo ""
echo "🎯 下一步操作:"
echo ""
echo "1. 📤 推送代码触发新工作流:"
echo "   git add . && git commit -m 'fix: 修复Docker部署问题' && git push"
echo ""
echo "2. 🔐 配置SSH密钥（如果需要）:"
echo "   ./generate-ssh-key.sh"
echo ""
echo "3. 🔍 验证镜像:"
echo "   GITHUB_TOKEN=your_token ./verify-image.sh"
echo ""
echo "4. 🚀 手动拉取测试:"
echo "   docker pull ghcr.io/helloimcx/diancan-food-ordering:backend-latest"
echo ""
echo "💡 如果SSH配置有问题，可以使用Railway等替代方案快速部署"
