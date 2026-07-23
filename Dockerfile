# ASUKA 訂位確認生成器 — 純靜態單檔工具,用 nginx 提供服務
FROM nginx:alpine

# 移除預設站台,放入我們的設定與工具本體
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ >/dev/null 2>&1 || exit 1
