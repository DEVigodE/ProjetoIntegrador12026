import { useKeycloak } from '@react-keycloak/web';

interface HeaderProps {
  title: string;
}

export default function Header({ title }: HeaderProps) {
  const { keycloak } = useKeycloak();
  const userName =
    keycloak.tokenParsed?.name ||
    keycloak.tokenParsed?.preferred_username ||
    'Usuario';

  return (
    <header className="bg-white shadow-sm px-6 py-4 flex items-center justify-between">
      <h2 className="text-xl font-semibold text-gray-800">{title}</h2>

      <div className="flex items-center gap-4">
        <span className="text-sm text-gray-600">{userName}</span>
        <button
          onClick={() => keycloak.logout()}
          className="text-sm text-gray-500 hover:text-gray-700 transition-colors"
        >
          Sair
        </button>
      </div>
    </header>
  );
}
