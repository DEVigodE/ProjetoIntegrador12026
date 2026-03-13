import { useKeycloak } from '@react-keycloak/web';
import { NavLink } from 'react-router-dom';
import { useOrderNotificationStore } from '../../store/orderNotificationStore';

interface NavItem {
  path: string;
  label: string;
  roles: string[];
}

const navItems: NavItem[] = [
  { path: '/dashboard', label: 'Dashboard', roles: ['ADMIN', 'OPERATOR'] },
  { path: '/orders', label: 'Pedidos', roles: ['ADMIN', 'OPERATOR'] },
  { path: '/products', label: 'Produtos', roles: ['ADMIN', 'OPERATOR'] },
  { path: '/couriers', label: 'Entregadores', roles: ['ADMIN', 'DISPATCHER'] },
  { path: '/deliveries', label: 'Entregas', roles: ['ADMIN', 'DISPATCHER'] },
  { path: '/reports', label: 'Relatorios', roles: ['ADMIN'] },
  { path: '/settings', label: 'Configuracoes', roles: ['ADMIN'] },
];

export default function Sidebar() {
  const { keycloak } = useKeycloak();
  const userRoles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];
  const pendingCount = useOrderNotificationStore((s) => s.pendingCount);

  const visibleItems = navItems.filter((item) =>
    item.roles.some((role) => userRoles.includes(role))
  );

  return (
    <aside className="w-60 bg-sidebar text-white flex flex-col min-h-screen">
      <div className="p-4 border-b border-white/10">
        <h1 className="text-lg font-bold text-primary-500">Delivery Backoffice</h1>
      </div>

      <nav className="flex-1 py-4">
        {visibleItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center justify-between px-4 py-3 text-sm transition-colors ${
                isActive
                  ? 'bg-white/10 text-primary-500 border-r-2 border-primary-500'
                  : 'text-gray-300 hover:bg-white/5 hover:text-white'
              }`
            }
          >
            <span>{item.label}</span>
            {item.path === '/orders' && pendingCount > 0 && (
              <span className="bg-red-500 text-white text-xs font-bold rounded-full px-2 py-0.5 min-w-[20px] text-center">
                {pendingCount}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      <div className="p-4 border-t border-white/10">
        <button
          onClick={() => keycloak.logout()}
          className="w-full text-left text-sm text-gray-400 hover:text-white transition-colors"
        >
          Sair
        </button>
      </div>
    </aside>
  );
}
