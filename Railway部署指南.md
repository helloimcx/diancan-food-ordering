# 🚀 Railway后端部署指南

## 🎯 准备工作
Railway CLI已安装成功，但需要登录才能部署。

## 📋 部署步骤

### 1. 登录Railway
在终端中运行：
```bash
cd /Users/yinyin/code/diancan/server
railway login
```

这会打开浏览器进行GitHub认证登录。

### 2. 初始化项目
登录成功后，初始化Railway项目：
```bash
railway init
```

### 3. 部署应用
```bash
railway up
```

### 4. 获取API URL
部署完成后，获取应用的公网访问地址：
```bash
railway domain
```

## 🔧 自动化部署脚本

### 选项A：使用railway.json配置
在server目录创建railway.json：
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm start",
    "healthcheckPath": "/",
    "healthcheckTimeout": 300
  }
}
```

### 选项B：使用环境变量
确保`server.js`中的端口配置正确：
```javascript
const PORT = process.env.PORT || 3001;
```

## 📊 部署后状态
- ✅ API服务：https://your-app.railway.app
- ✅ 数据库：SQLite文件自动上传
- ✅ 前端配置：需要更新VITE_API_URL环境变量

## 🔗 前端配置更新
Railway部署成功后，您需要：

1. **获取Railway提供的API URL**（类似：https://xxx.railway.app）
2. **在Vercel项目中设置环境变量**：
   - 访问：https://vercel.com/dashboard/projects/diancan-food-ordering
   - 进入 Settings → Environment Variables
   - 添加：`VITE_API_URL = https://your-railway-app.railway.app/api`

## 🚨 注意事项
- Railway免费额度：每月100小时运行时间
- SQLite数据库在容器重启时会重置，建议升级到PostgreSQL
- API请求会自动包含CORS支持

---
当前状态：✅ 准备就绪，等待登录和部署