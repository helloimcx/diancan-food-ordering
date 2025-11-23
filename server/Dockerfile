# 改进的后端Dockerfile - 家庭点餐系统
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 创建app用户（安全最佳实践）
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

# 复制package.json和package-lock.json
COPY package*.json ./

# 验证package.json是否存在
RUN if [ ! -f package.json ]; then echo "❌ package.json not found!"; exit 1; fi

# 安装依赖
RUN npm install --production

# 验证npm install是否成功
RUN ls -la node_modules/ && echo "✅ Dependencies installed"

# 复制应用代码
COPY . .

# 验证关键文件存在
RUN echo "🔍 验证关键文件:" && \
    if [ -f server.js ]; then echo "✅ server.js exists"; else echo "❌ server.js missing"; fi && \
    if [ -f database.js ]; then echo "✅ database.js exists"; else echo "❌ database.js missing"; fi && \
    if [ -f package.json ]; then echo "✅ package.json exists"; else echo "❌ package.json missing"; fi

# 创建必要的目录
RUN mkdir -p uploads && \
    chown -R nodeuser:nodejs /app

# 暴露端口
EXPOSE 3001

# 切换到nodeuser用户
USER nodeuser

# 健康检查（使用node而不是curl）
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/foods', (res) => {process.exit(res.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"

# 启动应用
CMD ["npm", "start"]
