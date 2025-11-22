# 家庭点餐应用 - Vercel 部署包

## 🚀 快速部署步骤

### 方法1: Vercel CLI 部署 (推荐)
```bash
# 1. 全局安装Vercel CLI
npm install -g vercel

# 2. 在当前目录运行部署
vercel

# 3. 选择部署配置
# - Set up and deploy "~/deployment-package"? [Y/n] y
# - Which scope do you want to deploy to? (选择您的账号)
# - Link to existing project? [y/N] n
# - What's your project's name? diancan
# - In which directory is your code located? ./
# - Want to override the settings? [y/N] n

# 4. 等待部署完成，获得访问地址
```

### 方法2: 拖拽部署 (最简单)
```bash
# 1. 访问 https://vercel.com
# 2. 登录或注册账号
# 3. 点击 "New Project"
# 4. 拖拽 deployment-package 文件夹到部署页面
# 5. 配置项目名称: diancan
# 6. 点击 "Deploy"
# 7. 等待部署完成
```

### 方法3: GitHub 集成部署
```bash
# 1. 将 deployment-package 上传到GitHub仓库
# 2. 在Vercel连接GitHub仓库
# 3. 自动部署配置: 默认即可
# 4. 每次代码更新自动重新部署
```

## 📱 部署后使用

### 前端应用
- **访问地址**: https://your-app.vercel.app
- **手机访问**: 直接在手机浏览器打开
- **添加到桌面**: 
  - iPhone: Safari → 分享 → 添加到主屏幕
  - Android: Chrome → 菜单 → 添加到主屏幕

### 后端API
- **当前隧道**: https://diancan-auth.loca.lt (密码: fan)
- **API地址**: https://diancan-auth.loca.lt/api
- **功能**: 完整的点餐API服务

## ✅ 功能验证

部署成功后，您可以测试：
- ✅ 浏览菜单和分类筛选
- ✅ 添加菜品到购物车
- ✅ 管理收藏夹
- ✅ 查看订单历史
- ✅ 菜品管理 (管理员功能)

## 💡 升级提示

### 当前配置
- 前端: Vercel (云端CDN)
- 后端: 本地隧道 (需要保持电脑开机)

### 完整云部署 (推荐)
如需前后端都在云端，参考 `./免费云平台一键部署.sh`

## 📞 技术支持

如遇到问题：
1. 检查Vercel控制台的部署日志
2. 确认域名解析是否正常
3. 查看浏览器控制台的网络错误
4. 尝试清除浏览器缓存

## 🎉 恭喜

您现在拥有了一个完整的云端点餐应用！
可以在任何地方用手机访问给老婆点餐了。

❤️ 祝用餐愉快！