# defi-tools-page

一个极简静态页面：`/index.html`

用途：

- 输入用户地址后，一键查询 YEAP USDT / YEAP USDC 两种包装代币的 `preview_redeem`（无需手动输入资源类型）
- 根据 Yeap Vault 的份额模型，计算“当前可赎回 USDC/USDT”和“当前份额价值”
- 可直接从 Aptos Fullnode 读取资源字段进行手动映射计算

直接打开：

- 本地双击 `index.html`
- 或使用本地静态服务（推荐，可直接请求 Fullnode）：

```bash
cd /home/runner/work/defi-tools-page/defi-tools-page
python3 -m http.server 8080
```

然后访问 `http://127.0.0.1:8080/index.html`。
