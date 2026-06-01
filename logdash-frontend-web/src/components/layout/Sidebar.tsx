import { useKeycloak } from '@react-keycloak/web';
import {
  BarChart3,
  ClipboardList,
  ChevronLeft,
  ChevronRight,
  Home,
  LogOut,
  Package,
  Tags,
  Truck,
  Users,
  type LucideIcon,
} from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { useOrderNotificationStore } from '../../store/orderNotificationStore';
import logoFull from '../../assets/logdash_extenso.png';
import logoIcon from '../../assets/logdash_icon.png';

interface NavItem {
  path: string;
  label: string;
  roles: string[];
  icon: LucideIcon;
}

const navItems: NavItem[] = [
  {
    path: '/dashboard',
    label: 'Dashboard',
    roles: ['ADMIN', 'OPERATOR'],
    icon: Home,
  },
  {
    path: '/orders',
    label: 'Pedidos',
    roles: ['ADMIN', 'OPERATOR'],
    icon: ClipboardList,
  },
  {
    path: '/products',
    label: 'Produtos',
    roles: ['ADMIN', 'OPERATOR'],
    icon: Package,
  },
  {
    path: '/settings',
    label: 'Categorias',
    roles: ['ADMIN'],
    icon: Tags,
  },
  {
    path: '/couriers',
    label: 'Entregadores',
    roles: ['ADMIN', 'DISPATCHER'],
    icon: Users,
  },
  {
    path: '/deliveries',
    label: 'Entregas',
    roles: ['ADMIN', 'DISPATCHER'],
    icon: Truck,
  },
  {
    path: '/reports',
    label: 'Relatórios',
    roles: ['ADMIN'],
    icon: BarChart3,
  }
];

interface SidebarProps {
  collapsed: boolean;
  onToggle: () => void;
}

export default function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const { keycloak } = useKeycloak();
  const userRoles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];
  const pendingCount = useOrderNotificationStore((s) => s.pendingCount);

  const visibleItems = navItems.filter((item) =>
    item.roles.some((role) => userRoles.includes(role))
  );

  return (
    <aside
      className={`bg-sidebar text-white flex flex-col min-h-screen transition-[width] duration-300 ${
        collapsed ? 'w-16' : 'w-60'
      }`}
    >
      <div className="border-b border-white/10 flex items-center justify-center p-3">
        <NavLink
          to="/dashboard"
          className="flex items-center hover:opacity-90 transition-opacity"
          aria-label="Ir para o dashboard"
          title="Ir para o dashboard"
        >
          {collapsed ? (
            <img
              src={logoIcon}
              alt="LogDash"
              className="w-14 h-10 object-contain"
            />
          ) : (
            <img
              src={logoFull}
              alt="LogDash"
              className="h-14 object-contain"
            />
          )}
        </NavLink>
      </div>

      <div className="flex justify-center py-2">
        <button
          type="button"
          onClick={onToggle}
          className="flex h-6 w-6 items-center justify-center rounded-full text-white/80 transition-colors hover:bg-white/10 hover:text-white"
          aria-label={collapsed ? 'Expandir sidebar' : 'Recolher sidebar'}
          title={collapsed ? 'Expandir' : 'Recolher'}
        >
          {collapsed ? (
            <ChevronRight className="h-3.5 w-3.5" aria-hidden="true" />
          ) : (
            <ChevronLeft className="h-3.5 w-3.5" aria-hidden="true" />
          )}
        </button>
      </div>

      <nav className="flex-1 py-4">
        {visibleItems.map((item) => {
          const Icon = item.icon;

          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                `relative flex items-center text-sm transition-colors py-3 ${
                  collapsed ? 'justify-center px-2' : 'gap-3 px-4'
                } ${
                  isActive
                    ? `
                      bg-white/10
                      text-white
                      before:content-['']
                      before:absolute
                      before:left-0
                      before:top-[10%]
                      before:h-[80%]
                      before:w-1
                      before:bg-white
                      before:rounded-r-md
                    `
                    : 'text-white hover:bg-white/5 hover:text-white'
                }`
              }
              aria-label={item.label}
              title={item.label}
            >
              <Icon className="h-5 w-5 shrink-0" aria-hidden="true" />

              <span className={collapsed ? 'sr-only' : ''}>{item.label}</span>

              {!collapsed && item.path === '/orders' && pendingCount > 0 && (
                <span className="ml-auto bg-red-500 text-white text-xs font-bold rounded-full px-2 py-0.5 min-w-[20px] text-center">
                  {pendingCount}
                </span>
              )}
            </NavLink>
          );
        })}
      </nav>

      <div className="p-4 border-t border-white/10">
        <button
          onClick={() => keycloak.logout()}
          className={`w-full flex items-center text-sm text-white/80 hover:text-white transition-colors ${
            collapsed ? 'justify-center' : 'justify-start gap-3'
          }`}
          aria-label="Sair"
          title="Sair"
        >
          <LogOut className="h-5 w-5 shrink-0" aria-hidden="true" />

          {!collapsed && <span>Sair</span>}
        </button>
      </div>
    </aside>
  );
}