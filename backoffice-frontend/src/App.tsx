import { useKeycloak } from '@react-keycloak/web';

function App() {
  const { keycloak } = useKeycloak();

  const userName = keycloak.tokenParsed?.name || keycloak.tokenParsed?.preferred_username || 'Usuario';
  const roles = keycloak.tokenParsed?.realm_access?.roles?.filter(
    (r: string) => ['ADMIN', 'OPERATOR', 'DISPATCHER'].includes(r)
  ) ?? [];

  return (
    <div className="flex items-center justify-center h-screen bg-gray-50">
      <div className="bg-white rounded-lg shadow-md p-8 text-center">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">
          Delivery Backoffice
        </h1>
        <p className="text-gray-600 mb-1">
          Bem-vindo, <span className="font-semibold">{userName}</span>
        </p>
        {roles.length > 0 && (
          <p className="text-sm text-gray-500 mb-4">
            Roles: {roles.join(', ')}
          </p>
        )}
        <button
          onClick={() => keycloak.logout()}
          className="bg-primary-500 text-white px-6 py-2 rounded-md hover:bg-primary-600 transition-colors"
        >
          Sair
        </button>
      </div>
    </div>
  );
}

export default App;
