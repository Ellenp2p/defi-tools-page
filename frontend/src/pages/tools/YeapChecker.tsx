import { useState } from 'react';
import type { ChangeEvent } from 'react';
import { Block } from 'baseui/block';
import { HeadingLarge, ParagraphSmall } from 'baseui/typography';
import { Input } from 'baseui/input';
import { Button } from 'baseui/button';
import { Card, hasThumbnail } from 'baseui/card';
import { Spinner } from 'baseui/spinner';
import { useQuery } from '@tanstack/react-query';
import { aptos, formatUnits } from '../../lib/aptos';
import { TOKEN_DECIMALS, YEAP_WRAPPED, CONTRACTS } from '../../config/contracts';

type RedeemMap = Record<string, string>;

export default function YeapChecker() {
  const [userAddress, setUserAddress] = useState('');

  const { data: redeemMap, isLoading, error, refetch } = useQuery<RedeemMap | null>({
    queryKey: ['yeapRedeem', userAddress],
    queryFn: async () => {
      if (!userAddress) return null;
      const entries = Object.entries(YEAP_WRAPPED) as [string, string][];
      const results: RedeemMap = {};

      await Promise.all(
        entries.map(async ([symbol, metadataAddr]) => {
          try {
            const res = await aptos.view({
              payload: {
                function: `${CONTRACTS.HELPER}::yeap::get_withdraw_by_user`,
                functionArguments: [userAddress, metadataAddr],
              },
            });
            const v = Array.isArray(res) ? String(res[0]) : String(res);
            results[symbol] = v;
          } catch (err) {
            console.error('preview_redeem 查询失败', symbol, err);
            results[symbol] = '0';
          }
        }),
      );

      return results;
    },
    enabled: !!userAddress,
  });

  const handleQuery = () => refetch();

  return (
    <Block padding="scale800">
      <HeadingLarge style={{ marginBottom: 8 }}>Yeap 可提取金额检查</HeadingLarge>
      <ParagraphSmall style={{ marginBottom: 16 }}>
        输入用户地址，页面会对 Yeap 包装的 USDT/USDC 调用合约（preview_redeem），并显示可提取数量。
      </ParagraphSmall>

      <Card hasThumbnail={hasThumbnail} overrides={{ Root: { style: { marginBottom: '16px' } } }}>
        <Block display="flex" gridGap="16px">
          <Input
            value={userAddress}
            onChange={(e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => setUserAddress(e.target.value)}
            placeholder="输入 Aptos 地址，例如 0x..."
            clearOnEscape
          />
          <Button onClick={handleQuery} disabled={!userAddress || isLoading}>
            {isLoading ? <Spinner $size={18} /> : '查询可提取金额'}
          </Button>
        </Block>
      </Card>

      {error && (
        <Card hasThumbnail={hasThumbnail} overrides={{ Root: { style: { marginBottom: '16px' } } }}>
          <Block color="negative500">查询失败: {error instanceof Error ? error.message : '未知错误'}</Block>
        </Card>
      )}

      <Card hasThumbnail={hasThumbnail} overrides={{}}>
        <Block marginBottom="8px">
          <HeadingLarge style={{ margin: 0, fontSize: '16px' }}>查询结果</HeadingLarge>
        </Block>

        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee' }}>
              <th style={{ padding: '8px' }}>代币</th>
              <th style={{ padding: '8px', textAlign: 'right' }}>可提取数量</th>
            </tr>
          </thead>
          <tbody>
            {Object.entries(YEAP_WRAPPED).map(([symbol]) => (
              <tr key={symbol} style={{ borderBottom: '1px solid #fafafa' }}>
                <td style={{ padding: '8px' }}>{symbol}</td>
                <td style={{ padding: '8px', textAlign: 'right' }}>
                  {isLoading && !redeemMap ? (
                    <Spinner $size={16} />
                  ) : (
                    <strong>
                      {redeemMap && redeemMap[symbol]
                        ? formatUnits(redeemMap[symbol], TOKEN_DECIMALS[symbol as 'USDC' | 'USDT'])
                        : '0'}
                    </strong>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>

      <Card hasThumbnail={hasThumbnail} overrides={{ Root: { style: { marginTop: '16px' } } }}>
        <Block>
          <HeadingLarge style={{ fontSize: '16px' }}>说明</HeadingLarge>
          <ParagraphSmall>自动使用下列 Yeap 包装代币作为查询参数：</ParagraphSmall>
          <ul>
            {Object.entries(YEAP_WRAPPED).map(([s, a]) => (
              <li key={s}>
                {s}: {a}
              </li>
            ))}
          </ul>
          <ParagraphSmall color="mono600">
            如果需要使用不同的代币地址，请在源码中修改 `YEAP_WRAPPED` 或扩展此 UI 以支持手动输入地址。
          </ParagraphSmall>
        </Block>
      </Card>
    </Block>
  );
}
