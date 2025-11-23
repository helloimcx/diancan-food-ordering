#!/bin/bash

# GitHub Container Registry权限问题修复脚本
# 解决镜像推送时的403 "invalid token"错误

echo "🔧 修复GitHub Container Registry权限问题..."

# 创建Personal Access Token配置指南
cat > PERSONAL_ACCESS_TOKEN_SETUP.md << 'EOF'
# 🔑 GitHub Personal Access Token设置指南

## 问题背景
GitHub Container Registry推送失败，状态码403 "invalid token"

## 解决方案：使用Personal Access Token

### 步骤1：创建Personal Access Token
1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 选择权限：
   - ✅ `repo` (完整仓库访问权限)
   - ✅ `write:packages` (推送到GitHub Packages)
   - ✅ `delete:packages` (删除GitHub Packages)
   - ✅ `admin:org` (管理组织包)

### 步骤2：保存Token
创建的token格式类似：`ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**安全提醒**：绝不要在代码中硬编码token！

### 步骤3：配置GitHub Secrets
在仓库设置中添加以下secrets：
- `PERSONAL_ACCESS_TOKEN`: 你的完整personal access token
- `REGISTRY_USERNAME`: 你的GitHub用户名

### 步骤4：更新GitHub Actions
使用以下配置替换默认的GITHUB_TOKEN：

```yaml
- name: 登录GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```
EOF

# 创建自动配置脚本
cat > setup-pat-auth.sh << 'EOF'
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
EOF

chmod +x setup-pat-auth.sh

echo ""
echo "🔧 权限问题修复工具已创建！"
echo ""
echo "📋 修复选项："
echo ""
echo "选项1：使用默认GITHUB_TOKEN（已修复权限）"
echo "✅ 已添加 packages: write 权限"
echo "📤 执行：git add . && git commit -m 'fix: 修复GitHub Container Registry权限' && git push"
echo ""
echo "选项2：使用Personal Access Token（更可靠）"
echo "📖 详细指南：PERSONAL_ACCESS_TOKEN_SETUP.md"
echo "🔧 配置脚本：./setup-pat-auth.sh"
echo ""
echo "💡 建议先尝试选项1，如果仍有问题再使用选项2"