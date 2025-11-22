#!/bin/bash

# 一键部署脚本 - 家庭点餐系统
# 支持开发模式和生产模式部署

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示标题
show_banner() {
    echo ""
    echo "🍽️ 家庭点餐系统 - 一键部署脚本"
    echo "=============================================="
    echo ""
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装，请先安装 Node.js"
        exit 1
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装，请先安装 npm"
        exit 1
    fi
    
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    log_success "Node.js $NODE_VERSION 和 npm $NPM_VERSION 已就绪"
}

# 停止现有服务
stop_existing_services() {
    log_info "检查并停止现有服务..."
    
    # 停止后端服务
    if pgrep -f "node.*server.js" > /dev/null; then
        log_info "发现运行中的后端服务，正在停止..."
        pkill -f "node.*server.js"
        sleep 2
    fi
    
    # 停止前端服务
    if pgrep -f "vite" > /dev/null; then
        log_info "发现运行中的前端服务，正在停止..."
        pkill -f "vite"
        sleep 2
    fi
    
    log_success "现有服务已停止"
}

# 安装依赖
install_dependencies() {
    log_info "安装项目依赖..."
    
    # 安装后端依赖
    log_info "安装后端依赖..."
    cd server
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        npm install
    else
        log_info "后端依赖已存在，跳过安装"
    fi
    cd ..
    
    # 安装前端依赖
    log_info "安装前端依赖..."
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        npm install
    else
        log_info "前端依赖已存在，跳过安装"
    fi
    
    log_success "依赖安装完成"
}

# 初始化数据库
init_database() {
    log_info "初始化数据库..."
    cd server
    if [ -f "init-db.js" ]; then
        npm run init-db
        log_success "数据库初始化完成"
    else
        log_warning "数据库初始化脚本不存在，跳过此步骤"
    fi
    cd ..
}

# 健康检查
health_check() {
    local service=$1
    local url=$2
    local max_attempts=10
    local attempt=1
    
    log_info "等待 $service 服务启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            log_success "$service 服务健康检查通过"
            return 0
        fi
        
        log_info "等待 $service 服务启动中... ($attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    log_error "$service 服务启动失败"
    return 1
}

# 启动服务
start_services() {
    local mode=${1:-"development"}
    
    if [ "$mode" = "production" ]; then
        log_info "启动生产模式服务..."
        
        # 启动后端服务
        log_info "启动后端API服务 (端口 3001)..."
        cd server
        nohup npm start > ../logs/backend.log 2>&1 &
        BACKEND_PID=$!
        cd ..
        echo $BACKEND_PID > logs/backend.pid
        
        # 构建前端
        log_info "构建前端应用..."
        npm run build
        
        # 这里可以添加生产环境的Web服务器启动逻辑
        log_warning "生产模式：前端构建完成，请配置Web服务器提供静态文件"
        
    else
        log_info "启动开发模式服务..."
        
        # 启动后端服务
        log_info "启动后端API服务 (端口 3001)..."
        cd server
        nohup npm start > ../logs/backend.log 2>&1 &
        BACKEND_PID=$!
        cd ..
        echo $BACKEND_PID > logs/backend.pid
        
        # 启动前端开发服务器
        log_info "启动前端开发服务器 (端口 5173)..."
        nohup npm run dev > logs/frontend.log 2>&1 &
        FRONTEND_PID=$!
        echo $FRONTEND_PID > logs/frontend.pid
        
        # 等待服务启动
        sleep 5
    fi
    
    log_success "服务启动完成"
}

# 显示服务状态
show_status() {
    echo ""
    echo "📊 服务状态"
    echo "=============="
    
    # 检查后端服务
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "后端API服务: ${GREEN}✅ 运行中${NC} (http://localhost:3001)"
    else
        echo -e "后端API服务: ${RED}❌ 未运行${NC}"
    fi
    
    # 检查前端服务
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo -e "前端开发服务器: ${GREEN}✅ 运行中${NC} (http://localhost:5173)"
    else
        echo -e "前端开发服务器: ${RED}❌ 未运行${NC}"
    fi
    
    echo ""
    echo "🔗 快速链接"
    echo "=============="
    echo -e "${BLUE}🏠 应用主页: ${NC}http://localhost:5173"
    echo -e "${BLUE}🔧 API接口: ${NC}http://localhost:3001/api"
    echo -e "${BLUE}❤️ 健康检查: ${NC}http://localhost:3001/health"
    echo ""
}

# 主函数
main() {
    # 创建日志目录
    mkdir -p logs
    
    # 显示标题
    show_banner
    
    # 检查是否提供了模式参数
    MODE=${1:-"development"}
    
    if [ "$MODE" = "production" ]; then
        log_info "选择生产模式部署"
    else
        log_info "选择开发模式部署"
    fi
    
    # 执行部署步骤
    check_dependencies
    stop_existing_services
    install_dependencies
    init_database
    start_services "$MODE"
    
    # 显示服务状态
    show_status
    
    if [ "$MODE" = "development" ]; then
        echo "🎉 开发环境部署完成！"
        echo ""
        echo "💡 使用提示:"
        echo "- 前端代码修改会自动热重载"
        echo "- 后端API实时可用"
        echo "- 按 Ctrl+C 停止服务"
        echo ""
        log_info "按任意键保持服务运行，或按 Ctrl+C 停止服务..."
        read -n 1 -s
    else
        echo "🎉 生产环境部署完成！"
        echo ""
        echo "📋 部署总结:"
        echo "- 后端服务: http://localhost:3001"
        echo "- 前端构建: dist/ 目录"
        echo "- 日志文件: logs/ 目录"
    fi
}

# 处理信号
trap 'log_info "收到停止信号，正在关闭服务..."; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0' INT TERM

# 检查参数
if [ "$1" = "stop" ]; then
    stop_existing_services
    log_success "所有服务已停止"
    exit 0
elif [ "$1" = "status" ]; then
    show_status
    exit 0
fi

# 运行主程序
main "$@"