#!/bin/bash

echo "🔑 配置Personal Access Token身份验证..."

# 检查是否已存在必要的secrets
if [ ! -f "secrets-config.env" ]; then
    echo "⚠️ 未找到secrets配置"
    echo "📋 请手动配置以下GitHub Secrets："
    echo ""
    echo "PERSONAL_ACCESS_TOKEN=ghp_your_token_here"
    echo "REGISTRY_USERNAME=your_github_username"
    echo ""
    echo "访问：https://github.com/helloimcx/diancan-food-ordering/settings/secrets/actions"
    exit 1
fi

source secrets-config.env

echo "🔧 创建支持Personal Access Token的工作流..."

cat > .github/workflows/pat-deploy.yml << PAT_EOF
name: Personal Access Token部署

on:
  push:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: \${{ github.repository }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
    - name: 检出代码
      uses: actions/checkout@v4

    - name: 设置Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: 登录GitHub Container Registry (使用PAT)
      uses: docker/login-action@v3
      with:
        registry: \${{ env.REGISTRY }}
        username: \${{ secrets.REGISTRY_USERNAME }}
        password: \${{ secrets.PERSONAL_ACCESS_TOKEN }}

    - name: 构建和推送Docker镜像
      uses: docker/build-push-action@v6
      with:
        context: ./server
        push: true
        tags: |
          \${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:backend-latest
          \${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: 验证镜像推送 (使用PAT)
      run: |
        echo "🔍 验证镜像推送..."
        
        sleep 60
        
        TOKEN="\${{ secrets.PERSONAL_ACCESS_TOKEN }}"
        
        echo "🔐 使用Personal Access Token验证..."
        RESPONSE=\$(curl -s -o /dev/null -w "%{http_code}" \
          -H "Authorization: token \$TOKEN" \
          -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
          "https://ghcr.io/v2/\${{ env.IMAGE_NAME }}/manifests/backend-latest")
        
        echo "验证响应码: \$RESPONSE"
        
        if [ "\$RESPONSE" = "200" ]; then
          echo "✅ 镜像推送成功！"
        else
          echo "⚠️ 镜像验证失败，尝试获取更多信息..."
          curl -s -H "Authorization: token \$TOKEN" \
            "https://ghcr.io/v2/\${{ env.IMAGE_NAME }}/tags/list" | jq '.'
        fi
PAT_EOF

echo "✅ 创建了Personal Access Token工作流：.github/workflows/pat-deploy.yml"
echo ""
echo "🎯 下一步操作："
echo "1. 设置Personal Access Token（参考：PERSONAL_ACCESS_TOKEN_SETUP.md）"
echo "2. 添加GitHub Secrets"
echo "3. 推送代码测试：git push"
