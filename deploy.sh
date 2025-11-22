#!/bin/bash

# 点餐系统部署脚本

echo "🚀 开始部署点餐系统..."

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

echo "✅ Node.js 已安装"

# 安装后端依赖
echo "📦 安装后端依赖..."
cd server
npm install
echo "✅ 后端依赖安装完成"

# 初始化数据库
echo "🗄️ 初始化数据库..."
npm run init-db
echo "✅ 数据库初始化完成"

# 启动后端服务
echo "🔧 启动后端服务..."
npm start &
BACKEND_PID=$!
echo "✅ 后端服务启动成功 (PID: $BACKEND_PID)"

# 返回根目录
cd ..

# 安装前端依赖
echo "📦 安装前端依赖..."
npm install
echo "✅ 前端依赖安装完成"

# 构建前端应用
echo "🏗️ 构建前端应用..."
npm run build
echo "✅ 前端应用构建完成"

echo ""
echo "🎉 部署完成！"
echo "📍 后端API服务: http://localhost:3001"
echo "📍 前端应用: 请使用Web服务器提供静态文件"
echo ""
echo "💡 提示:"
echo "- 后端服务已在后台运行"
echo "- 前端构建文件位于 dist/ 目录"
echo "- 生产环境请配置反向代理或Nginx"
echo ""

# 等待用户按键
read -p "按任意键继续..." -n 1 -s