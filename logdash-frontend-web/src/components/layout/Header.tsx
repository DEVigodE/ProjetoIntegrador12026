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
    <header className="flex items-center justify-between border-b border-gray-200/70 bg-white px-6 py-4 shadow-sm">
      <h2 className="text-xl font-semibold text-gray-800">{title}</h2>

      <div className="flex items-center gap-4">
        <span className="text-sm text-gray-700">{userName}</span>
        <button
          onClick={() => keycloak.logout()}
          className="text-sm text-gray-600 hover:text-gray-900 transition-colors"
        >
          Sair
        </button>
      </div>
    </header>
  );
}
