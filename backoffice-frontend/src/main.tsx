import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { ReactKeycloakProvider } from '@react-keycloak/web';
import { QueryClientProvider } from '@tanstack/react-query';
import keycloak from './config/keycloak';
import queryClient from './config/queryClient';
import App from './App';
import './index.css';

function AuthLoadingScreen() {
  return (
    <div className="flex items-center justify-center h-screen bg-gray-50">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto" />
        <p className="mt-4 text-gray-600">Autenticando...</p>
      </div>
    </div>
  );
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ReactKeycloakProvider
      authClient={keycloak}
      initOptions={{ onLoad: 'login-required', pkceMethod: 'S256' }}
      LoadingComponent={<AuthLoadingScreen />}
    >
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    </ReactKeycloakProvider>
  </StrictMode>,
);
