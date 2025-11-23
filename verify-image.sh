#!/bin/bash

echo "🔍 验证Docker镜像..."

# 检查镜像是否存在
echo "检查镜像: ghcr.io/helloimcx/diancan-food-ordering:backend-latest"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/helloimcx/diancan-food-ordering/manifests/backend-latest"

echo ""
echo "获取所有可用标签:"
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://ghcr.io/v2/helloimcx/diancan-food-ordering/tags/list" | jq '.'
