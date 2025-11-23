# 🎯 Railway后端部署 - 快速开始

## 🚀 一键部署（推荐）

运行自动化部署脚本：
```bash
cd /Users/yinyin/code/diancan
./railway-deploy.sh
```

## 📋 手动部署步骤

如果自动脚本遇到问题，可以手动执行：

### 1. 进入server目录
```bash
cd /Users/yinyin/code/diancan/server
```

### 2. 登录Railway
```bash
railway login
```
（会打开浏览器进行GitHub认证）

### 3. 初始化项目
```bash
railway init --name "diancan-backend"
```

### 4. 部署
```bash
railway up
```

### 5. 获取API地址
```bash
railway domain
```

## 🔗 前端配置更新

Railway部署成功后：

1. **复制API地址**（例如：`https://xxx.railway.app`）
2. **更新Vercel环境变量**：
   - 访问：https://vercel.com/dashboard/projects/diancan-food-ordering
   - 进入 `Settings` → `Environment Variables`
   - 添加：`VITE_API_URL = https://your-railway-app.railway.app/api`
3. **重新部署前端**：Vercel会自动检测到配置变更

## ✅ 验证部署

部署完成后，访问以下地址验证：
- **后端API**：`https://your-railway-app.railway.app/api/foods`
- **前端应用**：https://diancan-food-ordering.vercel.app

## 🎉 完成！

部署成功后，您的点餐应用将具备：
- ✅ 云端数据持久化
- ✅ 手机/电脑随时访问
- ✅ 完整的菜品管理功能
- ✅ 订单和收藏功能

---
准备开始部署！运行 `./railway-deploy.sh` 即可。