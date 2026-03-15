import axios from 'axios';
import keycloak from './keycloak';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
});

api.interceptors.request.use(async (config) => {
  if (keycloak.authenticated) {
    try {
      if (keycloak.isTokenExpired(30)) {
        await keycloak.updateToken(30);
      }
    } catch {
      keycloak.login();
      return Promise.reject(new Error('Session expired'));
    }
    if (keycloak.token) {
      config.headers.Authorization = `Bearer ${keycloak.token}`;
    }
  }
  return config;
});

export default api;
