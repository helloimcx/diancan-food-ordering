#!/bin/bash

# GitHub Actions配置验证脚本
# 验证阿里云Docker部署所需的配置

echo "🔍 GitHub Actions配置验证"
echo "=========================="

# 检查工作流文件
echo "📋 检查GitHub Actions工作流..."
WORKFLOW_FILE=".github/workflows/deploy-alicloud.yml"
if [ -f "$WORKFLOW_FILE" ]; then
    echo "✅ 工作流文件存在: $WORKFLOW_FILE"
    
    # 检查触发条件
    if grep -q "paths:" "$WORKFLOW_FILE"; then
        echo "✅ 工作流有路径触发条件"
        grep -A 3 "paths:" "$WORKFLOW_FILE" | head -4
    else
        echo "⚠️ 工作流缺少路径触发条件"
    fi
    
    # 检查必需的环境变量
    if grep -q "ALICLOUD_HOST" "$WORKFLOW_FILE"; then
        echo "✅ 工作流配置了阿里云服务器主机"
    else
        echo "❌ 工作流缺少阿里云服务器主机配置"
    fi
else
    echo "❌ 工作流文件不存在: $WORKFLOW_FILE"
fi

echo ""

# 检查Docker配置
echo "🐳 检查Docker配置..."
DOCKERFILE="server/Dockerfile"
if [ -f "$DOCKERFILE" ]; then
    echo "✅ Dockerfile存在: $DOCKERFILE"
    
    # 检查基础镜像
    if grep -q "FROM node:" "$DOCKERFILE"; then
        echo "✅ 基础镜像配置正确"
        grep "FROM node:" "$DOCKERFILE"
    else
        echo "⚠️ 基础镜像配置需要检查"
    fi
    
    # 检查端口配置
    if grep -q "EXPOSE" "$DOCKERFILE"; then
        echo "✅ 端口配置存在"
        grep "EXPOSE" "$DOCKERFILE"
    else
        echo "⚠️ 端口配置缺失"
    fi
else
    echo "❌ Dockerfile不存在: $DOCKERFILE"
fi

echo ""

# 检查服务器设置文件
echo "🛠️ 检查服务器设置文件..."
if [ -f "server-setup.sh" ]; then
    echo "✅ 服务器设置脚本存在"
    
    # 检查是否包含Docker安装
    if grep -q "docker" "server-setup.sh"; then
        echo "✅ 包含Docker安装"
    else
        echo "⚠️ 缺少Docker安装步骤"
    fi
    
    # 检查是否包含安全组提示
    if grep -q "安全组" "server-setup.sh"; then
        echo "✅ 包含安全组配置提示"
    else
        echo "⚠️ 缺少安全组配置提示"
    fi
else
    echo "❌ 服务器设置脚本不存在"
fi

echo ""

# 检查SSH配置
echo "🔐 检查SSH配置..."
if [ -f "generate-ssh-key.sh" ]; then
    echo "✅ SSH密钥生成脚本存在"
else
    echo "❌ SSH密钥生成脚本不存在"
fi

echo ""

# 检查GitHub Secrets状态
echo "📋 检查GitHub Secrets配置状态..."
echo "请访问以下URL检查Secrets配置："
echo "https://github.com/helloimcx/diancan-food-ordering/settings/secrets/actions"
echo ""
echo "必需配置的Secrets："
echo "✅ ALICLOUD_HOST"
echo "✅ ALICLOUD_USER" 
echo "✅ ALICLOUD_PRIVATE_KEY"
echo "✅ ALICLOUD_PORT"

echo ""

# 显示部署架构
echo "🗺️ 部署架构检查"
echo "==============="
echo "GitHub仓库 → GitHub Actions → GitHub Container Registry → 阿里云服务器"
echo ""

# 检查最近的工作流运行
echo "📊 检查最近的GitHub Actions运行..."
echo "访问以下URL查看部署状态："
echo "https://github.com/helloimcx/diancan-food-ordering/actions"

echo ""

# 提供下一步指南
echo "🚀 下一步操作指南"
echo "=================="
echo ""
echo "如果配置完整，按以下步骤进行："
echo ""
echo "1. 生成SSH密钥:"
echo "   ./generate-ssh-key.sh"
echo ""
echo "2. 配置阿里云服务器:"
echo "   scp server-setup.sh root@YOUR_SERVER_IP:/root/"
echo "   ssh root@YOUR_SERVER_IP"
echo "   ./server-setup.sh"
echo ""
echo "3. 配置GitHub Secrets"
echo ""
echo "4. 推送代码触发部署:"
echo "   git add server/"
echo "   git commit -m '测试阿里云Docker部署'"
echo "   git push origin main"
echo ""
echo "如果遇到问题，查看:"
echo "- 部署失败诊断.md"
echo "- 阿里云部署状态报告.md"

echo ""
echo "✅ 配置验证完成！"