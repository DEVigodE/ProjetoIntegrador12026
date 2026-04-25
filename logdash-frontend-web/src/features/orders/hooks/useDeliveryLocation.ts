import { useEffect, useRef, useState } from 'react';
import type { IMessage } from '@stomp/stompjs';
import { getStompClient } from '../../../services/websocket';

export interface LocationUpdate {
  courierId: string;
  deliveryId: number;
  orderId: number;
  latitude: number;
  longitude: number;
  status: string;
  timestamp: string;
}

export function useDeliveryLocation(orderId: number | undefined, active: boolean) {
  const [location, setLocation] = useState<LocationUpdate | null>(null);
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null);

  useEffect(() => {
    if (!orderId || !active) return;

    const client = getStompClient();

    function subscribe() {
      try {
        subscriptionRef.current = client.subscribe(
          `/topic/order/${orderId}/location`,
          (message: IMessage) => {
            const loc: LocationUpdate = JSON.parse(message.body);
            setLocation(loc);
          }
        );
      } catch {
        // silent — reconecta via onConnect
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
  }, [orderId, active]);

  return { location };
}
