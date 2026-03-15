import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';
import keycloak from '../config/keycloak';

let stompClient: Client | null = null;

export function getStompClient(): Client {
  if (!stompClient) {
    stompClient = new Client({
      webSocketFactory: () =>
        new SockJS(`${import.meta.env.VITE_WS_URL}?token=${keycloak.token}`),
      reconnectDelay: 5000,
    });
  }
  return stompClient;
}
