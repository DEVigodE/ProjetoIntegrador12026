import { useEffect, useRef, useState } from 'react';
import type { IMessage } from '@stomp/stompjs';
import { getStompClient } from '../../../services/websocket';

export interface CourierLocation {
  courierId: string;
  deliveryId: number;
  orderId: number;
  latitude: number;
  longitude: number;
  status: string;
  timestamp: string;
}

export function useDeliveryLocationWebSocket(orderId: number | undefined) {
  const [location, setLocation] = useState<CourierLocation | null>(null);
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null);

  useEffect(() => {
    if (!orderId) return;

    const client = getStompClient();

    function subscribe() {
      try {
        subscriptionRef.current = client.subscribe(
          `/topic/order/${orderId}/location`,
          (message: IMessage) => {
            const loc: CourierLocation = JSON.parse(message.body);
            setLocation(loc);
          }
        );
      } catch {
        // localização simplesmente não atualiza se a subscrição falhar
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

  return location;
}
