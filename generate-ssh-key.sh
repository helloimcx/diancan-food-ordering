#!/bin/bash

# SSH密钥生成和配置脚本
# 用于GitHub Actions部署到阿里云服务器

echo "🔐 生成SSH密钥用于GitHub Actions部署..."

# 检查是否已存在密钥
if [ -f ~/.ssh/id_rsa ]; then
    echo "⚠️ 现有SSH密钥已存在"
    read -p "是否覆盖现有密钥？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 取消操作"
        exit 1
    fi
fi

# 生成新的SSH密钥对
echo "🔑 生成新的SSH密钥对..."
ssh-keygen -t rsa -b 4096 -C "github-actions@alicloud" -f ~/.ssh/id_rsa -N ""

# 设置正确的权限
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 显示公钥内容
echo ""
echo "✅ SSH密钥生成完成！"
echo ""
echo "📋 步骤1: 将以下公钥添加到阿里云服务器"
echo "复制以下内容到服务器 ~/.ssh/authorized_keys:"
echo ""
cat ~/.ssh/id_rsa.pub
echo ""
echo "📋 步骤2: 设置GitHub Secrets"
echo "在GitHub仓库的Settings → Secrets中添加："
echo ""
echo "ALICLOUD_PRIVATE_KEY:"
cat ~/.ssh/id_rsa | sed 's/^/  /'
echo ""
echo "ALICLOUD_HOST: YOUR_SERVER_IP"
echo "ALICLOUD_USER: root (或您的用户名)"
echo "ALICLOUD_PORT: 22"
echo ""

# 测试SSH连接
echo "📋 步骤3: 测试SSH连接"
echo "请执行以下命令测试连接（需要先配置服务器）："
echo "ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP"
echo ""

# 保存配置信息
cat > ~/.ssh/deploy-config.txt << EOF
# 阿里云服务器SSH部署配置
# 生成时间: $(date)

## 公钥 (添加到服务器 ~/.ssh/authorized_keys)
$(cat ~/.ssh/id_rsa.pub)

## 私钥 (添加到GitHub Secrets - ALICLOUD_PRIVATE_KEY)
$(cat ~/.ssh/id_rsa)

## GitHub Secrets 配置
ALICLOUD_PRIVATE_KEY: [上述私钥内容]
ALICLOUD_HOST: YOUR_SERVER_IP
ALICLOUD_USER: root
ALICLOUD_PORT: 22

## 服务器配置命令
# 1. 上传公钥到服务器
scp ~/.ssh/id_rsa.pub root@YOUR_SERVER_IP:~/

# 2. 登录服务器并添加公钥
ssh root@YOUR_SERVER_IP
mkdir -p ~/.ssh
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
rm ~/id_rsa.pub

# 3. 测试连接
ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP
EOF

echo "💾 配置信息已保存到: ~/.ssh/deploy-config.txt"
echo ""
echo "🎯 下一步:"
echo "1. 将公钥添加到阿里云服务器"
echo "2. 将私钥添加到GitHub Secrets"
echo "3. 运行服务器初始化: ./server-setup.sh"
echo "4. 推送代码触发自动部署"