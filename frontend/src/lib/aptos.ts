import { Aptos, AptosConfig, Network } from '@aptos-labs/ts-sdk';
import { DEFAULT_NETWORK } from '../config/contracts';

// 创建 Aptos 客户端配置
const config = new AptosConfig({
  network: Network.MAINNET,
  fullnode: DEFAULT_NETWORK,
});

// 导出 Aptos 客户端实例
export const aptos = new Aptos(config);

// 格式化 BigInt 为可读字符串
export function formatUnits(value: bigint | string | number, decimals: number, fractionDigits = 6): string {
  const raw = typeof value === 'bigint' ? value : BigInt(value);
  const base = BigInt(10) ** BigInt(decimals);
  const negative = raw < 0n;
  const abs = negative ? -raw : raw;
  const intPart = abs / base;
  const fracPart = abs % base;
  let frac = fracPart.toString().padStart(decimals, '0').slice(0, fractionDigits);
  frac = frac.replace(/0+$/, '');
  return `${negative ? '-' : ''}${intPart.toString()}${frac ? '.' + frac : ''}`;
}

// 解析字符串为 BigInt
export function parseBigInt(value: string): bigint {
  const s = String(value).trim();
  if (!/^-?\d+$/.test(s)) {
    throw new Error(`Invalid BigInt: ${s}`);
  }
  return BigInt(s);
}
