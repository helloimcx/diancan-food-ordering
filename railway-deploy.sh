#!/bin/bash

# Railway后端部署脚本
echo "🚀 开始Railway后端部署..."

# 1. 检查Railway CLI
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI未安装，正在安装..."
    npm install -g @railway/cli
fi

# 2. 检查登录状态
echo "🔐 检查Railway登录状态..."
if ! railway whoami &> /dev/null; then
    echo "❌ 未登录Railway，正在打开登录页面..."
    railway login
fi

# 3. 进入server目录
cd /Users/yinyin/code/diancan/server

# 4. 初始化项目
echo "🏗️ 初始化Railway项目..."
railway init --name "diancan-backend"

# 5. 部署
echo "🚀 开始部署..."
railway up

# 6. 获取域名
echo "🔗 获取API地址..."
railway domain

echo "✅ 部署完成！"
echo "📝 下一步："
echo "1. 复制上面的API地址"
echo "2. 在Vercel项目设置中添加环境变量 VITE_API_URL"
echo "3. 重新部署前端应用"