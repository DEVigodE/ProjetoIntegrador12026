import { useKeycloak } from '@react-keycloak/web';
import { Outlet } from 'react-router-dom';

export default function PrivateRoute() {
  const { keycloak, initialized } = useKeycloak();

  if (!initialized) {
    return null;
  }

  if (!keycloak.authenticated) {
    keycloak.login();
    return null;
  }

  return <Outlet />;
}
