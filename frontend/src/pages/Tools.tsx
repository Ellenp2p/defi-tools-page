import { Link, Outlet, useLocation } from 'react-router-dom';
import { Block } from 'baseui/block';
import { HeadingLarge } from 'baseui/typography';
import { Button } from 'baseui/button';

const drawerWidth = 240;

const tools = [
  {
    name: 'Yeap USDT/USDC 检查',
    path: '/tools/yeap-checker',
    description: '查看和提取 Yeap Vault 中的代币',
  },
];

export default function Tools() {
  const location = useLocation();

  return (
    <Block $style={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      <Block as="header" $style={{ position: 'fixed', width: '100%', height: '64px', backgroundColor: '#fff', borderBottom: '1px solid #eee', display: 'flex', alignItems: 'center', padding: '0 16px', zIndex: 1 }}>
        <HeadingLarge style={{ margin: 0 }}>DeFi Tools</HeadingLarge>
      </Block>

      <Block $style={{ marginTop: '64px', display: 'flex', flex: 1 }}>
        <Block $style={{ width: `${drawerWidth}px`, padding: '16px', borderRight: '1px solid #eee', minHeight: 'calc(100vh - 64px)' }}>
          {tools.map((tool) => (
            <div key={tool.path} style={{ marginBottom: 12 }}>
              <Link to={tool.path} style={{ textDecoration: 'none' }}>
                <Button kind={location.pathname === tool.path ? 'primary' : 'tertiary'}>{tool.name}</Button>
              </Link>
            </div>
          ))}
        </Block>

        <Block $style={{ flex: 1, padding: '24px' }}>
          <Outlet />
        </Block>
      </Block>
    </Block>
  );
}
