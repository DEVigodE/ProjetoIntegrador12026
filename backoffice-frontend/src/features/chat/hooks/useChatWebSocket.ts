import { useEffect, useRef, useState, useCallback } from 'react';
import type { IMessage } from '@stomp/stompjs';
import { useKeycloak } from '@react-keycloak/web';
import { getStompClient } from '../../../services/websocket';
import api from '../../../config/axios';
import type { MessageResponse } from '../types/chat.types';

export function useChatWebSocket(orderId: number | undefined) {
  const [messages, setMessages] = useState<MessageResponse[]>([]);
  const [connected, setConnected] = useState(false);
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null);
  const { keycloak } = useKeycloak();

  useEffect(() => {
    if (!orderId) return;

    const client = getStompClient();

    function subscribe() {
      try {
        subscriptionRef.current = client.subscribe(
          `/topic/chat/${orderId}`,
          (message: IMessage) => {
            const msg: MessageResponse = JSON.parse(message.body);
            setMessages((prev) => [...prev, msg]);
          }
        );
        setConnected(true);
      } catch {
        setConnected(false);
      }
    }

    const previousOnConnect = client.onConnect;
    client.onConnect = (frame) => {
      previousOnConnect?.call(client, frame);
      subscribe();
    };

    if (client.connected) {
      subscribe();
    } else if (!client.active) {
      client.activate();
    }

    return () => {
      subscriptionRef.current?.unsubscribe();
      subscriptionRef.current = null;
      client.onConnect = previousOnConnect ?? (() => {});
    };
  }, [orderId]);

  const sendMessage = useCallback(
    async (content: string) => {
      if (!orderId) return;

      const senderId =
        keycloak.tokenParsed?.preferred_username ??
        keycloak.tokenParsed?.sub ??
        'unknown';
      const roles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];
      const senderType = roles.includes('ADMIN')
        ? 'ADMIN'
        : roles.includes('OPERATOR')
          ? 'OPERATOR'
          : roles.includes('DISPATCHER')
            ? 'DISPATCHER'
            : 'STORE';
      const payload = { senderId, senderType, content };

      const { data } = await api.post<MessageResponse>(
        `/api/chat/${orderId}/messages`,
        payload
      );
      setMessages((prev) => [...prev, data]);
    },
    [orderId, keycloak.tokenParsed]
  );

  return { messages, sendMessage, connected };
}
