import { useEffect, useRef, useState, useCallback } from 'react';
import type { IMessage } from '@stomp/stompjs';
import { getStompClient } from '../../../services/websocket';
import type { MessageResponse } from '../types/chat.types';

export function useChatWebSocket(orderId: number | undefined) {
  const [messages, setMessages] = useState<MessageResponse[]>([]);
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null);

  useEffect(() => {
    if (!orderId) return;

    const client = getStompClient();

    function onConnect() {
      subscriptionRef.current = client.subscribe(
        `/topic/chat/${orderId}`,
        (message: IMessage) => {
          const msg: MessageResponse = JSON.parse(message.body);
          setMessages((prev) => [...prev, msg]);
        }
      );
    }

    client.onConnect = onConnect;

    if (!client.active) {
      client.activate();
    } else {
      onConnect();
    }

    return () => {
      subscriptionRef.current?.unsubscribe();
      subscriptionRef.current = null;
    };
  }, [orderId]);

  const sendMessage = useCallback(
    (content: string) => {
      if (!orderId) return;
      const client = getStompClient();
      client.publish({
        destination: `/app/chat/${orderId}/send`,
        body: JSON.stringify({ content }),
      });
    },
    [orderId]
  );

  return { messages, sendMessage };
}
