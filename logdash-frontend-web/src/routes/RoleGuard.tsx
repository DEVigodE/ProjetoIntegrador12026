import { useKeycloak } from '@react-keycloak/web';
import type { ReactNode } from 'react';

interface RoleGuardProps {
  roles: string[];
  children: ReactNode;
}

export default function RoleGuard({ roles, children }: RoleGuardProps) {
  const { keycloak } = useKeycloak();
  const userRoles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];

  const hasAccess = roles.some((role) => userRoles.includes(role));

  if (!hasAccess) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-800 mb-2">Acesso negado</h2>
          <p className="text-gray-600">
            Voce nao tem permissao para acessar esta pagina.
          </p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
