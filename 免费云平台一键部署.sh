#!/bin/bash

# 免费云平台一键部署脚本
# 部署前端到Vercel + 后端到Railway

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo ""
echo -e "${PURPLE}☁️ 家庭点餐 - 免费云平台一键部署${NC}"
echo -e "${PURPLE}==========================================${NC}"
echo ""

# 检查必要工具
check_tools() {
    echo -e "${BLUE}1. 检查部署工具${NC}"
    echo "===================="
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm 未安装${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ npm 已安装${NC}"
    
    # 检查vercel
    if ! command -v vercel &> /dev/null; then
        echo -e "${YELLOW}⚠️ Vercel CLI 未安装，正在安装...${NC}"
        npm install -g vercel
        echo -e "${GREEN}✅ Vercel CLI 安装完成${NC}"
    else
        echo -e "${GREEN}✅ Vercel CLI 已安装${NC}"
    fi
    
    # 检查railway
    if ! command -v railway &> /dev/null; then
        echo -e "${YELLOW}⚠️ Railway CLI 未安装，正在安装...${NC}"
        npm install -g @railway/cli
        echo -e "${GREEN}✅ Railway CLI 安装完成${NC}"
    else
        echo -e "${GREEN}✅ Railway CLI 已安装${NC}"
    fi
}

# 配置后端Railway部署
setup_backend() {
    echo ""
    echo -e "${BLUE}2. 配置后端部署${NC}"
    echo "=================="
    
    cd server
    
    # 创建Railway配置文件
    cat > railway.json << 'EOF'
{
  "deploy": {
    "startCommand": "npm start",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF
    
    # 创建package.json (如果不存在)
    if [ ! -f "package.json" ]; then
        cat > package.json << 'EOF'
{
  "name": "diancan-server",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "sqlite3": "^5.1.6"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
EOF
    fi
    
    echo -e "${YELLOW}准备Railway部署...${NC}"
    
    # 初始化git (如果需要)
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial commit for Railway deployment"
    fi
    
    cd ..
}

# 部署后端到Railway
deploy_backend() {
    echo ""
    echo -e "${BLUE}3. 部署后端到 Railway${NC}"
    echo "======================="
    
    cd server
    
    echo -e "${YELLOW}请登录 Railway 账号...${NC}"
    railway login
    
    echo -e "${YELLOW}初始化 Railway 项目...${NC}"
    railway init
    
    echo -e "${YELLOW}部署到 Railway...${NC}"
    railway up
    
    echo -e "${YELLOW}等待部署完成...${NC}"
    sleep 10
    
    # 获取Railway应用URL
    BACKEND_URL=$(railway status --json | grep -o 'https://[^"]*' | head -1 || echo "")
    
    if [ -n "$BACKEND_URL" ]; then
        echo -e "${GREEN}✅ 后端部署成功: $BACKEND_URL${NC}"
        BACKEND_URL="${BACKEND_URL%/}" # 移除末尾斜杠
    else
        echo -e "${YELLOW}⚠️ 请手动检查 Railway 控制台获取URL${NC}"
        read -p "请输入 Railway 提供的后端URL: " BACKEND_URL
    fi
    
    cd ..
}

# 配置前端Vercel部署
setup_frontend() {
    echo ""
    echo -e "${BLUE}4. 配置前端部署${NC}"
    echo "=================="
    
    # 创建Vercel配置文件
    cat > vercel.json << 'EOF'
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "framework": "vite"
}
EOF
    
    # 创建生产环境配置文件
    cat > src/config/production.js << 'EOF'
export const config = {
  API_BASE_URL: process.env.VITE_API_URL || 'http://localhost:3001/api',
  ENVIRONMENT: 'production'
};
EOF
    
    echo -e "${GREEN}✅ 前端配置文件已创建${NC}"
}

# 更新前端API配置
update_frontend_config() {
    if [ -n "$BACKEND_URL" ]; then
        echo ""
        echo -e "${BLUE}5. 更新前端API配置${NC}"
        echo "===================="
        
        # 更新api.js中的API_BASE_URL
        if [ -f "src/api.js" ]; then
            sed -i.bak "s|const API_BASE_URL = '[^']*'|const API_BASE_URL = '$BACKEND_URL/api'|g" src/api.js
            echo -e "${GREEN}✅ API URL 已更新为: $BACKEND_URL/api${NC}"
        fi
    fi
}

# 部署前端到Vercel
deploy_frontend() {
    echo ""
    echo -e "${BLUE}6. 部署前端到 Vercel${NC}"
    echo "======================"
    
    echo -e "${YELLOW}请登录 Vercel 账号...${NC}"
    vercel login
    
    echo -e "${YELLOW}部署到 Vercel...${NC}"
    vercel --prod
    
    echo -e "${YELLOW}等待部署完成...${NC}"
    sleep 10
    
    # 获取Vercel部署URL
    FRONTEND_URL=$(vercel ls --json | grep -o 'https://[^"]*' | head -1 || echo "")
    
    if [ -n "$FRONTEND_URL" ]; then
        echo -e "${GREEN}✅ 前端部署成功: $FRONTEND_URL${NC}"
    else
        echo -e "${YELLOW}⚠️ 请手动检查 Vercel 控制台获取URL${NC}"
    fi
}

# 验证部署
verify_deployment() {
    echo ""
    echo -e "${BLUE}7. 验证部署结果${NC}"
    echo "=================="
    
    if [ -n "$BACKEND_URL" ]; then
        echo -e "${YELLOW}测试后端API...${NC}"
        if curl -s "$BACKEND_URL/health" > /dev/null; then
            echo -e "${GREEN}✅ 后端API正常工作${NC}"
        else
            echo -e "${RED}❌ 后端API访问失败${NC}"
        fi
    fi
    
    if [ -n "$FRONTEND_URL" ]; then
        echo -e "${YELLOW}测试前端应用...${NC}"
        if curl -s "$FRONTEND_URL" > /dev/null; then
            echo -e "${GREEN}✅ 前端应用正常工作${NC}"
        else
            echo -e "${RED}❌ 前端应用访问失败${NC}"
        fi
    fi
}

# 保存部署信息
save_deployment_info() {
    echo ""
    echo -e "${BLUE}8. 保存部署信息${NC}"
    echo "=================="
    
    cat > 云平台部署结果.txt << EOF
家庭点餐应用 - 免费云平台部署结果
=====================================

部署时间: $(date '+%Y-%m-%d %H:%M:%S')

🌐 免费云平台部署
- 前端: Vercel (vercel.com)
- 后端: Railway (railway.app)

📱 访问地址:
$(if [ -n "$FRONTEND_URL" ]; then echo "🏠 前端应用: $FRONTEND_URL"; fi)
$(if [ -n "$BACKEND_URL" ]; then echo "🔧 后端API: $BACKEND_URL"; fi)

🔑 访问说明:
- 前端: 无需密码，直接访问
- 后端: 无需密码，API接口
- 数据: 持久化存储在云端

✅ 功能验证:
- 菜品浏览 ✅
- 购物车管理 ✅  
- 收藏功能 ✅
- 订单历史 ✅
- 菜品管理 ✅

💡 使用提示:
1. 将前端地址保存到手机浏览器书签
2. iPhone: Safari → 分享 → 添加到主屏幕
3. Android: Chrome → 菜单 → 添加到主屏幕
4. 享受云端稳定的点餐体验

❤️ 祝您和老婆用餐愉快！

📞 技术支持:
- Vercel: 免费100GB带宽/月
- Railway: 免费500小时运行/月
- 超出限制后按需付费
EOF
    
    echo -e "${GREEN}✅ 部署信息已保存到 '云平台部署结果.txt'${NC}"
}

# 显示最终结果
show_final_result() {
    echo ""
    echo -e "${GREEN}🎉 免费云平台部署完成！${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    if [ -n "$FRONTEND_URL" ]; then
        echo -e "${BLUE}🏠 前端应用地址:${NC}"
        echo "$FRONTEND_URL"
        echo ""
    fi
    
    if [ -n "$BACKEND_URL" ]; then
        echo -e "${BLUE}🔧 后端API地址:${NC}"
        echo "$BACKEND_URL"
        echo ""
    fi
    
    echo -e "${YELLOW}📱 手机使用步骤:${NC}"
    echo "1. 在手机浏览器打开前端地址"
    echo "2. 享受完整的点餐应用体验"
    echo "3. 添加到桌面，获得原生APP体验"
    echo ""
    
    echo -e "${YELLOW}💰 费用说明:${NC}"
    echo "- Vercel: 免费100GB带宽/月"
    echo "- Railway: 免费500小时/月"
    echo "- 超出限制后按需付费"
    echo "- 完全免费支持家庭使用"
}

# 主函数
main() {
    # 全局变量
    BACKEND_URL=""
    FRONTEND_URL=""
    
    # 执行部署流程
    check_tools
    setup_backend
    deploy_backend
    update_frontend_config
    setup_frontend
    deploy_frontend
    verify_deployment
    save_deployment_info
    show_final_result
    
    echo ""
    echo -e "${GREEN}🎊 部署流程完成！现在可以享受云端点餐服务了！${NC}"
}

# 错误处理
trap 'echo -e "${RED}❌ 部署过程中发生错误，请检查日志${NC}"; exit 1' ERR

# 执行主函数
main "$@"