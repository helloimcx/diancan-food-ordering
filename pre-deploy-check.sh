#!/bin/bash

# 阿里云部署预检查脚本
# 用于验证部署前的环境准备情况

echo "🔍 阿里云部署环境预检查"
echo "=================================="

# 检查GitHub仓库
echo "📋 检查GitHub仓库配置..."
if [ -f ".github/workflows/deploy-alicloud.yml" ]; then
    echo "✅ GitHub Actions工作流文件存在"
else
    echo "❌ GitHub Actions工作流文件缺失"
    exit 1
fi

# 检查Docker文件
echo "🐳 检查Docker配置..."
if [ -f "server/Dockerfile" ]; then
    echo "✅ Dockerfile存在"
else
    echo "❌ Dockerfile缺失"
    exit 1
fi

# 检查服务器设置文件
echo "🛠️ 检查服务器设置文件..."
if [ -f "server-setup.sh" ]; then
    echo "✅ 服务器设置脚本存在"
else
    echo "❌ 服务器设置脚本缺失"
    exit 1
fi

# 检查SSH密钥生成脚本
echo "🔐 检查SSH配置..."
if [ -f "generate-ssh-key.sh" ]; then
    echo "✅ SSH密钥生成脚本存在"
else
    echo "❌ SSH密钥生成脚本缺失"
    exit 1
fi

echo ""
echo "🗺️ 部署架构检查"
echo "==================="
echo "GitHub仓库 → GitHub Actions → GitHub Container Registry → 阿里云服务器"
echo ""

# 检查GitHub CLI是否可用
echo "🔍 检查GitHub CLI..."
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI已安装"
    gh auth status 2>/dev/null && echo "✅ 已登录GitHub" || echo "⚠️ 需要登录GitHub"
else
    echo "⚠️ GitHub CLI未安装（可选）"
fi

# 检查SSH连接配置
echo ""
echo "📋 GitHub Secrets配置检查"
echo "========================="
echo "请在GitHub仓库设置中配置以下Secrets："
echo ""
echo "ALICLOUD_HOST: YOUR_SERVER_IP"
echo "ALICLOUD_USER: root"
echo "ALICLOUD_PRIVATE_KEY: [SSH私钥内容]"
echo "ALICLOUD_PORT: 22"
echo ""

# 阿里云服务器要求检查
echo "📋 阿里云服务器要求"
echo "=================="
echo "✅ 操作系统: CentOS 7/8 或 Ubuntu 18.04+"
echo "✅ 内存: 至少1GB"
echo "✅ 磁盘: 至少10GB可用空间"
echo "✅ 网络: 公网IP地址"
echo ""

# 安全组端口要求
echo "📋 阿里云安全组配置"
echo "==================="
echo "在阿里云控制台中为ECS实例安全组添加："
echo "✅ 3001 (TCP) - 后端API服务"
echo "✅ 22 (TCP) - SSH访问"
echo ""

# 部署步骤指南
echo "🚀 下一步操作指南"
echo "=================="
echo ""
echo "📝 步骤1: 生成SSH密钥 (2分钟)"
echo "  ./generate-ssh-key.sh"
echo ""
echo "📝 步骤2: 配置阿里云服务器 (10分钟)"
echo "  scp server-setup.sh root@YOUR_SERVER_IP:/root/"
echo "  ssh root@YOUR_SERVER_IP"
echo "  ./server-setup.sh"
echo ""
echo "📝 步骤3: 设置GitHub Secrets (3分钟)"
echo "  在GitHub仓库Settings → Secrets中添加配置"
echo ""
echo "📝 步骤4: 配置阿里云安全组 (5分钟)"
echo "  在阿里云控制台中添加端口3001和22"
echo ""
echo "📝 步骤5: 测试自动部署 (10分钟)"
echo "  git add server/"
echo "  git commit -m '测试阿里云Docker部署'"
echo "  git push origin main"
echo ""

# 故障排除提示
echo "🔧 故障排除"
echo "============"
echo "如果部署失败："
echo "1. 检查GitHub Actions日志"
echo "2. 验证SSH连接: ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP"
echo "3. 确认Docker安装: ssh root@YOUR_SERVER_IP 'docker --version'"
echo "4. 检查端口占用: ssh root@YOUR_SERVER_IP 'netstat -tlnp | grep 3001'"
echo ""

# 替代方案
echo "🛑 替代方案"
echo "==========="
echo "如果阿里云部署遇到问题，可以使用："
echo "1. Railway部署: ./railway-deploy.sh"
echo "2. 手动部署: 在服务器上运行 ./server-setup.sh && ./deploy.sh"
echo ""

echo "✅ 预检查完成！"
echo "请按照上述步骤继续配置。"