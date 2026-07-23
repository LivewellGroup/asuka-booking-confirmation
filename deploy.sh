#!/usr/bin/env bash
# ASUKA 訂位確認生成器 — 一鍵部署 / 更新
# 首次執行會自動 git clone,之後會自動 git pull,跑完自我驗證。
# 用法(在 happy 伺服器上):
#   curl -fsSL https://raw.githubusercontent.com/LivewellGroup/asuka-booking-confirmation/main/deploy.sh | bash
set -euo pipefail

REPO="https://github.com/LivewellGroup/asuka-booking-confirmation.git"
DIR="${ASUKA_DIR:-$HOME/docker/asuka-invoice}"

if [ -d "$DIR/.git" ]; then
  echo "→ 更新現有部署:$DIR"
  git -C "$DIR" pull --ff-only
else
  echo "→ 首次部署:$DIR"
  mkdir -p "$(dirname "$DIR")"
  git clone "$REPO" "$DIR"
fi

cd "$DIR"
echo "→ 建置並啟動容器…"
docker compose up -d --build

echo "→ 等待啟動…"
sleep 3
if curl -fsS http://localhost:8090/ 2>/dev/null | head -1 | grep -qi doctype; then
  echo ""
  echo "✅ 部署成功!本機測試網址:http://localhost:8090"
  echo "   對外請確認 Cloudflare Tunnel 已指向 http://localhost:8090"
else
  echo ""
  echo "⚠️  容器已啟動但 curl 驗證未通過,請檢查:docker compose logs -f"
fi
