# ASUKA 訂位確認生成器 — 部署指南

## 這個專案是什麼

**純靜態單一 HTML 工具,沒有後端、沒有資料庫。**
客戶在頁面上填的訂位資料只存在他自己瀏覽器的 localStorage,不會上傳、不經過伺服器、彼此看不到。
因此 Docker 裡只需要一個 nginx 靜態伺服器 — 不需要 PostgreSQL、不需要資料 volume、沒有備份或資料遷移的問題。

## 架構

```
File Server（內網原始碼存放 / 編輯）
  \\192.168.0.211\File Server\艾旅\(27)開發資料\ASUKA 訂位確認生成器
        │  git push
        ▼
GitHub（唯一真實來源 source of truth）
  https://github.com/LivewellGroup/asuka-booking-confirmation
        │  git clone / git pull（在 happy 伺服器上）
        ▼
happy@100.123.104.63 — Docker（nginx:alpine 靜態）
  容器內 80  →  host 8090
        │
        ▼
Cloudflare Tunnel  →  https://asukainvoice.livewellgroup.com.tw
```

- **對外 Port：`8090`**（host 端；Cloudflare Tunnel 指向 `http://localhost:8090`）
- 若 8090 已被其他服務占用，改 `docker-compose.yml` 裡 `"8090:80"` 左邊的數字，並同步改 tunnel 設定。

---

## 首次部署（在 happy 伺服器上執行）

```bash
# 1. SSH 進伺服器
ssh happy@100.123.104.63

# 2. 取得專案（建議放在你慣用的 docker 專案目錄，例如 ~/docker）
mkdir -p ~/docker && cd ~/docker
git clone https://github.com/LivewellGroup/asuka-booking-confirmation.git asuka-invoice
cd asuka-invoice

# 3. 建置並啟動（背景執行、開機自動重啟）
docker compose up -d --build

# 4. 驗證（應回傳 HTML）
curl -s http://localhost:8090/ | head -5
```

看到 HTML 開頭（`<!DOCTYPE html>` …）就代表跑起來了。

---

## 更新（工具改版後，重新部署）

工具的原始碼改動走 GitHub。伺服器端只要拉最新版再重建：

```bash
cd ~/docker/asuka-invoice
git pull
docker compose up -d --build
```

（nginx 對 `index.html` 設了 `no-cache`，客戶重新整理即可看到最新版。）

---

## Cloudflare Tunnel 設定

假設 happy 上已在跑 `cloudflared`（named tunnel）。在 tunnel 的 `config.yml` 的 `ingress` 加一條：

```yaml
ingress:
  - hostname: asukainvoice.livewellgroup.com.tw
    service: http://localhost:8090
  # … 你原本其他的 ingress 規則 …
  - service: http_status:404
```

然後建立 DNS 路由（會自動在 Cloudflare 建 CNAME）：

```bash
cloudflared tunnel route dns <你的-tunnel-名稱> asukainvoice.livewellgroup.com.tw
```

重載 cloudflared（依你的安裝方式）：

```bash
sudo systemctl restart cloudflared
# 或若 cloudflared 也是 docker： docker restart cloudflared
```

完成後開 https://asukainvoice.livewellgroup.com.tw 應可看到工具。

---

## 常見操作

| 需求 | 指令 |
|------|------|
| 看容器狀態 | `docker compose ps` |
| 看日誌 | `docker compose logs -f` |
| 停止 | `docker compose down` |
| 重啟 | `docker compose restart` |
| 確認 8090 是否被占用 | `sudo ss -ltnp \| grep 8090` |

---

## 備註

- 目前 GitHub Pages（https://livewellgroup.github.io/asuka-booking-confirmation/）仍在線，可當作備援；自架站穩定後要不要關閉 Pages 由你決定。
- 這是給客戶填寫的工具，含艾旅預設收款帳號 — 與 Pages 版本一樣屬於對外可見資訊。若日後想限制存取（例如 Cloudflare Access 加驗證），再另外設定。
