# 🚀 点餐系统部署指南

## 📋 部署架构

本点餐系统采用前后端分离架构，支持服务器部署和数据持久化：

```
┌─────────────────┐    HTTP     ┌─────────────────┐
│   前端应用      │ ◄────────► │   后端API服务   │
│  (React + Vite) │            │ (Node.js + API) │
└─────────────────┘            └─────────────────┘
         │                              │
    静态文件                       SQLite数据库
```

## 🛠️ 技术栈

### 前端
- **React 18** - 现代化UI框架
- **TypeScript** - 类型安全
- **Vite** - 快速构建工具
- **Bootstrap CSS** - 响应式设计

### 后端
- **Node.js + Express** - 服务器框架
- **SQLite3** - 轻量级数据库
- **CORS** - 跨域支持

## 📦 部署方式

### 方式一：使用部署脚本（推荐）

1. **运行部署脚本**
```bash
chmod +x deploy.sh
./deploy.sh
```

脚本会自动：
- 检查环境依赖
- 安装前后端依赖
- 初始化数据库
- 启动后端服务
- 构建前端应用

### 方式二：手动部署

1. **安装后端服务**
```bash
cd server
npm install
npm run init-db  # 初始化数据库
npm start        # 启动后端服务
```

2. **构建前端应用**
```bash
npm install      # 安装前端依赖
npm run build    # 构建生产版本
```

## 🌐 生产环境部署

### 方案一：Nginx反向代理

1. **部署后端服务**
```bash
cd server
npm install --production
npm start
```

2. **配置Nginx**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    # 前端静态文件
    location / {
        root /path/to/diancan/dist;
        try_files $uri $uri/ /index.html;
    }
    
    # 后端API代理
    location /api/ {
        proxy_pass http://localhost:3001/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 方案二：PM2进程管理

1. **安装PM2**
```bash
npm install -g pm2
```

2. **创建PM2配置文件**
```json
{
  "name": "diancan-server",
  "script": "server/server.js",
  "cwd": "/path/to/diancan",
  "instances": 1,
  "autorestart": true,
  "watch": false,
  "env": {
    "NODE_ENV": "production",
    "PORT": "3001"
  }
}
```

3. **启动服务**
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### 方案三：Docker部署

1. **创建Dockerfile**
```dockerfile
# 多阶段构建
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/server ./server
COPY --from=builder /app/dist ./dist
COPY server/package*.json ./
RUN cd server && npm install --production
EXPOSE 3001
CMD ["node", "server/server.js"]
```

2. **构建和运行**
```bash
docker build -t diancan .
docker run -p 3001:3001 diancan
```

## 🔧 环境配置

### 开发环境
- **前端开发**: `npm run dev` (端口5173)
- **后端开发**: `npm run dev` (端口3001)

### 生产环境
- **前端构建**: `npm run build`
- **后端服务**: `npm start`

## 📊 数据库管理

### SQLite数据库文件
- **位置**: `server/diancan.db`
- **自动创建**: 运行`npm run init-db`时创建

### 数据库表结构
1. **foods** - 菜品信息
2. **orders** - 订单主表
3. **order_items** - 订单详情
4. **favorites** - 收藏记录

### 数据备份
```bash
# 备份数据库
cp server/diancan.db backup/diancan-$(date +%Y%m%d).db

# 恢复数据库
cp backup/diancan-20231122.db server/diancan.db
```

## 🔒 安全配置

### CORS设置
```javascript
// server/server.js
app.use(cors({
  origin: ['http://localhost:5173', 'https://your-domain.com'],
  credentials: true
}));
```

### 环境变量
```bash
# .env
NODE_ENV=production
PORT=3001
DATABASE_URL=sqlite://./server/diancan.db
```

## 📈 监控和日志

### PM2监控
```bash
pm2 monitor
pm2 logs diancan-server
```

### 健康检查
```bash
curl http://localhost:3001/health
```

## 🛡️ 故障排除

### 常见问题

1. **端口占用**
```bash
# 查找占用端口的进程
lsof -i :3001
# 或
netstat -tulpn | grep 3001
```

2. **权限问题**
```bash
# 设置文件权限
chmod +x deploy.sh
chmod -R 755 server/
```

3. **依赖安装失败**
```bash
# 清除npm缓存
npm cache clean --force
# 重新安装
rm -rf node_modules package-lock.json
npm install
```

### 日志查看
```bash
# 后端日志
tail -f server/logs/app.log

# PM2日志
pm2 logs

# Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 📞 技术支持

如遇到部署问题，请检查：
1. Node.js版本是否符合要求（>= 16）
2. 端口3001是否被占用
3. 数据库文件权限是否正确
4. 网络防火墙设置

---

**💝 祝您部署成功！**