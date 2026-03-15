import axios from 'axios';
import { toast } from 'react-toastify';
import keycloak from './keycloak';
import type { ErrorResponse } from '../types/error.types';

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

const fallbackMessages: Record<number, string> = {
  403: 'Acesso negado',
  404: 'Recurso nao encontrado',
  400: 'Requisicao invalida',
  422: 'Operacao invalida',
  500: 'Erro interno do servidor',
};

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (!axios.isAxiosError(error) || !error.response) {
      return Promise.reject(error);
    }

    const { status, data } = error.response;

    if (status === 401) {
      keycloak.login();
      return Promise.reject(error);
    }

    const errorData = data as ErrorResponse | undefined;
    const message = errorData?.message || fallbackMessages[status] || 'Erro inesperado';

    toast.error(message);

    return Promise.reject(error);
  },
);

export default api;
