# 🔐 SSH密钥配置指南

## 🎯 立即可执行的SSH配置

### 方法1: 使用现有密钥 (如果已有)
```bash
# 检查现有密钥
ls -la ~/.ssh/

# 如果存在id_rsa，复制内容
cat ~/.ssh/id_rsa
```

### 方法2: 生成新密钥
```bash
# 生成新的SSH密钥对
ssh-keygen -t rsa -b 4096 -C "github-actions@alicloud" -f ~/.ssh/diancan-deploy -N ""

# 设置权限
chmod 600 ~/.ssh/diancan-deploy
chmod 644 ~/.ssh/diancan-deploy.pub
```

### 方法3: 使用GitHub CLI生成 (推荐)
```bash
# 使用GitHub CLI生成
gh ssh-key add ~/.ssh/diancan-deploy.pub --title "阿里云部署"

# 复制私钥内容
cat ~/.ssh/diancan-deploy
```

## 📋 GitHub Secrets配置

### 必需配置项
在 `https://github.com/helloimcx/diancan-food-ordering/settings/secrets/actions` 添加：

| 名称 | 值 |
|------|-----|
| ALICLOUD_HOST | 您的服务器公网IP |
| ALICLOUD_USER | root |
| ALICLOUD_PRIVATE_KEY | 完整的私钥内容 |
| ALICLOUD_PORT | 22 |

### 私钥格式示例
```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA....[完整私钥内容]....zA==
-----END RSA PRIVATE KEY-----
```

## 🔍 验证SSH连接

### 测试命令
```bash
# 测试SSH连接
ssh -i ~/.ssh/diancan-deploy -o StrictHostKeyChecking=no root@YOUR_SERVER_IP "echo 'SSH连接成功'"

# 如果成功，说明密钥配置正确
```

## 🛠️ 故障排除

### 常见问题
1. **权限错误**: `chmod 600 ~/.ssh/diancan-deploy`
2. **格式错误**: 确保包含BEGIN和END标记
3. **服务器未授权**: 在服务器上添加公钥到 `~/.ssh/authorized_keys`

### 服务器端配置
```bash
# 在阿里云服务器上执行
mkdir -p ~/.ssh
echo "您的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

## ⚡ 快速解决方案

如果SSH配置复杂，建议：

1. **立即使用Railway**: `./railway-deploy.sh`
2. **并行调试SSH**: 逐步完善阿里云配置
3. **后续迁移**: 完成后再迁移到自有服务器

---
**时间对比**: Railway 5分钟 vs 阿里云SSH调试 30分钟+