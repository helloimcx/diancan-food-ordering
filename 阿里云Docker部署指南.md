# 🏗️ 阿里云服务器Docker自动化部署指南

## 📋 概览
本指南将帮助您设置完整的CI/CD流程，当代码推送到main分支时，自动构建Docker镜像并部署到阿里云服务器。

## 🛠️ 系统架构
```
GitHub仓库 → GitHub Actions → GitHub Container Registry → 阿里云服务器 → Docker容器
```

## 🚀 部署步骤

### 第一步：配置阿里云服务器

#### 1.1 服务器要求
- **操作系统**: CentOS 7/8 或 Ubuntu 18.04+
- **内存**: 至少1GB
- **磁盘**: 至少10GB可用空间
- **Docker**: 将自动安装

#### 1.2 运行服务器初始化脚本
在阿里云服务器上以root权限执行：
```bash
# 上传脚本到服务器
scp server-setup.sh root@YOUR_SERVER_IP:/root/

# 登录服务器
ssh root@YOUR_SERVER_IP

# 运行初始化脚本
chmod +x server-setup.sh
./server-setup.sh
```

#### 1.3 配置阿里云安全组
在阿里云控制台中为您的ECS实例安全组添加端口：
- **3001** (TCP) - 后端API服务
- **22** (TCP) - SSH访问（可选）

### 第二步：配置GitHub Secrets

在GitHub仓库中设置以下Secrets：

1. **ALICLOUD_HOST**: 您的阿里云服务器公网IP地址
2. **ALICLOUD_USER**: SSH登录用户名（通常是root或ubuntu）
3. **ALICLOUD_PRIVATE_KEY**: SSH私钥内容
4. **ALICLOUD_PORT**: SSH端口（默认22）

#### 生成SSH密钥对：
```bash
# 在本地生成SSH密钥
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# 将公钥添加到服务器
ssh-copy-id root@YOUR_SERVER_IP

# 查看私钥内容并添加到GitHub Secrets
cat ~/.ssh/id_rsa
```

### 第三步：测试自动部署

#### 3.1 推送代码触发部署
```bash
# 提交并推送server目录的更改
git add server/
git commit -m "配置阿里云服务器Docker部署"
git push origin main
```

#### 3.2 监控部署状态
1. 访问GitHub仓库的Actions页面
2. 查看"阿里云服务器Docker部署"工作流的执行日志
3. 部署成功后，检查服务器容器状态

### 第四步：配置前端API地址

#### 4.1 获取阿里云API地址
部署成功后，API地址格式为：
```
http://YOUR_SERVER_IP:3001/api
```

#### 4.2 更新Vercel环境变量
在Vercel项目设置中添加：
```
VITE_API_URL=http://YOUR_SERVER_IP:3001/api
```

## 📁 文件结构

### GitHub仓库文件
```
├── .github/
│   └── workflows/
│       └── deploy-alicloud.yml    # GitHub Actions工作流
├── server/
│   ├── Dockerfile                 # Docker镜像构建配置
│   ├── package.json              # Node.js依赖配置
│   └── server.js                 # 后端服务代码
└── server-setup.sh               # 服务器初始化脚本
```

### 阿里云服务器文件
```
/opt/diancan-backend/
├── docker-compose.yml            # Docker Compose配置
├── deploy.sh                     # 自动部署脚本
├── service-manager.sh            # 服务管理脚本
├── health-check.sh               # 健康检查脚本
├── cleanup.sh                    # 清理脚本
├── data/                         # 数据库文件目录
└── logs/                         # 日志文件目录
```

## 🔧 常用管理命令

在阿里云服务器上运行：
```bash
cd /opt/diancan-backend

# 管理服务
./service-manager.sh start|stop|restart|logs|status|update

# 环境检查
./health-check.sh

# 清理资源
./cleanup.sh

# 手动部署
./deploy.sh
```

## 📊 监控和维护

### 日志查看
```bash
# 查看实时日志
./service-manager.sh logs

# 查看容器状态
docker ps

# 查看磁盘使用
df -h
```

### 健康检查
```bash
# 检查API健康状态
curl http://localhost:3001/api/foods

# 检查容器健康
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 备份数据
```bash
# 备份数据库
cp /opt/diancan-backend/data/diancan.db /opt/diancan-backend/data/backup-$(date +%Y%m%d-%H%M%S).db
```

## 🛡️ 安全建议

1. **SSH安全**:
   - 使用密钥认证而非密码
   - 更改默认SSH端口
   - 启用防火墙规则

2. **Docker安全**:
   - 定期更新Docker镜像
   - 使用非root用户运行容器
   - 限制容器资源使用

3. **网络安全**:
   - 仅开放必要端口
   - 使用HTTPS（生产环境）
   - 配置安全组规则

## 🔄 故障排除

### 常见问题

1. **部署失败**:
   - 检查GitHub Actions日志
   - 验证SSH连接
   - 确认Docker安装

2. **容器无法启动**:
   - 检查端口占用
   - 查看容器日志
   - 验证环境变量

3. **API无法访问**:
   - 检查防火墙设置
   - 验证阿里云安全组
   - 确认服务状态

### 调试命令
```bash
# 检查服务器环境
./health-check.sh

# 查看详细日志
docker logs diancan-backend

# 测试网络连接
curl -v http://localhost:3001/api/foods

# 检查磁盘空间
df -h && docker system df
```

## ✅ 部署验证

部署成功后，应该能够：
1. ✅ 访问GitHub Actions显示"✅"状态
2. ✅ 在服务器上看到diancan-backend容器运行
3. ✅ API响应：`curl http://YOUR_SERVER_IP:3001/api/foods`
4. ✅ 前端应用成功连接到API

---
**部署架构**: GitHub → GitHub Actions → GitHub Container Registry → 阿里云Docker
**优势**: 自动化部署、版本控制、容错恢复
**成本**: 阿里云服务器费用 + GitHub免费额度