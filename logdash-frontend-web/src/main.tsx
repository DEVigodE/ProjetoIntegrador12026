import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { ReactKeycloakProvider } from '@react-keycloak/web';
import { QueryClientProvider } from '@tanstack/react-query';
import keycloak from './config/keycloak';
import queryClient from './config/queryClient';
import AuthLayout from './layouts/AuthLayout';
import { ToastContainer } from 'react-toastify';
import App from './App';
import 'react-toastify/dist/ReactToastify.css';
import 'leaflet/dist/leaflet.css';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <ReactKeycloakProvider
    authClient={keycloak}
    initOptions={{ onLoad: 'login-required', pkceMethod: 'S256' }}
    LoadingComponent={<AuthLayout />}
  >
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
        <ToastContainer position="top-right" />
      </BrowserRouter>
    </QueryClientProvider>
  </ReactKeycloakProvider>,
);
