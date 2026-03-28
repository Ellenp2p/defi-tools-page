# defi-tools-page

一个极简静态页面：`/index.html`

用途：根据 Yeap Vault 的份额模型，计算“当前可赎回 USDC/USDT”和“当前份额价值”，并可直接从 Aptos Fullnode 读取资源字段进行计算。

直接打开：

- 本地双击 `index.html`（只用手动输入）
- 或使用本地静态服务（推荐，可直接请求 Fullnode）：

```bash
cd /home/runner/work/defi-tools-page/defi-tools-page
python3 -m http.server 8080
```

然后访问 `http://127.0.0.1:8080/index.html`。
