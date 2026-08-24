# ASUKA 訂位確認生成器

開始任何修改前,先完整閱讀 **`專案\ASUKA 行前通知\ASUKA工具-遷移與開發手冊.md`**(本機路徑;內含伺服器帳密,勿放入本 repo)——涵蓋本工具與姊妹工具(飛鳥Ⅲ 行前通知生成器)的架構、2026-08 視覺定稿(勿回退)、驗證方法、部署程序與所有領域知識。新電腦接手時,連同該資料夾一起遷移。

速記:
- 純靜態單一 HTML 工具,無後端無資料庫;客戶資料只存瀏覽器 localStorage(key `asuka-booking-confirm-v2`)。
- 工作檔=`index.html`,改完複製覆蓋 `ASUKA訂位確認生成器.html`(雙檔同步)後才部署。
- 部署一律走 git:commit → push → 伺服器 `git pull --ff-only && docker compose up -d --build`(容器 `asuka-invoice`,host port 8090)。**禁止 scp 覆蓋**,會弄髒伺服器工作樹。GitHub Pages 隨 push 自動更新作備援。
- 改版後必跑手冊 §6 的逐頁溢出驗證(iframe 逐頁量 `.pf` 頁尾 gap > 0);改字型後也要重驗。
- 改預設值(地址、證號、帳號、公司名等)必在 `normalizeData()` 加舊值遷移,讓客戶端舊 localStorage/舊 JSON 自動更新。
- 狀態用語固定「Booking · 已付款」/「Option · 待付款」;取消規定/日程表彩條色序是指定原版,勿改品牌色;匯款帳戶小標保留英文。
- 本工具需要 http 環境預覽(file:// 不行),用任一靜態伺服器即可。
