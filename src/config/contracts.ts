// Yeap 合约配置
export const CONTRACTS = {
  // Helper Contract - 用于调用 view 函数
  HELPER: '0x3c08a387060ae713be456be4f3e6226773801b9c147bf94e28c67f30c9edc88d',
  
  // Yeap Vault 合约
  VAULT: '0x7b90b95e1060d9d2e424c6687ba03cccaed6996cccd4868b759c9fca361fa70',
} as const;

// Aptos Mainnet 代币地址
export const TOKENS = {
  USDC: '0xbae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b',
  USDT: '0x357b0b74bc833e95a115ad22604854d6b0fca151cecd94111770e5d6ffc9dc2b',
} as const;

// 代币精度
export const TOKEN_DECIMALS = {
  USDC: 6,
  USDT: 6,
} as const;

// Yeap 套在 Vault 上的包装代币地址（用于 preview_redeem 查询）
export const YEAP_WRAPPED = {
  USDT: '0x560adc958571709b69d4dfaef2dd994b9e77758beddbf20c5ac584bfec08fe0c',
  USDC: '0x6dc2b4cd0edc7aecd0aefad2864af87a2cc992a01f8fcf3ff1434ae93a7ecf39',
} as const;

// 网络配置
export const NETWORK_CONFIG = {
  MAINNET: 'https://fullnode.mainnet.aptoslabs.com/v1',
  TESTNET: 'https://fullnode.testnet.aptoslabs.com/v1',
} as const;

// 默认使用主网
export const DEFAULT_NETWORK = NETWORK_CONFIG.MAINNET;
