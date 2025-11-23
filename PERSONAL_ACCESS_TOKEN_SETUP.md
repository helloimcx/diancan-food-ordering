# 🔑 GitHub Personal Access Token设置指南

## 问题背景
GitHub Container Registry推送失败，状态码403 "invalid token"

## 解决方案：使用Personal Access Token

### 步骤1：创建Personal Access Token
1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 选择权限：
   - ✅ `repo` (完整仓库访问权限)
   - ✅ `write:packages` (推送到GitHub Packages)
   - ✅ `delete:packages` (删除GitHub Packages)
   - ✅ `admin:org` (管理组织包)

### 步骤2：保存Token
创建的token格式类似：`ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**安全提醒**：绝不要在代码中硬编码token！

### 步骤3：配置GitHub Secrets
在仓库设置中添加以下secrets：
- `PERSONAL_ACCESS_TOKEN`: 你的完整personal access token
- `REGISTRY_USERNAME`: 你的GitHub用户名

### 步骤4：更新GitHub Actions
使用以下配置替换默认的GITHUB_TOKEN：

```yaml
- name: 登录GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```
