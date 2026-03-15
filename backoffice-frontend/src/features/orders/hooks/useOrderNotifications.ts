import { useEffect, useRef, useState } from 'react';
import { toast } from 'react-toastify';
import { useOrderNotificationStore } from '../../../store/orderNotificationStore';
import type { Order } from '../types/order.types';

export function useOrderNotifications(orders: Order[] | undefined) {
  const [hasNewOrders, setHasNewOrders] = useState(false);
  const prevPendingIdsRef = useRef<Set<number> | null>(null);
  const increment = useOrderNotificationStore((s) => s.increment);

  useEffect(() => {
    if (!orders) return;

    const currentPendingIds = new Set(
      orders.filter((o) => o.status === 'PENDING').map((o) => o.id)
    );

    if (prevPendingIdsRef.current === null) {
      prevPendingIdsRef.current = currentPendingIds;
      return;
    }

    const newIds: number[] = [];
    for (const id of currentPendingIds) {
      if (!prevPendingIdsRef.current.has(id)) {
        newIds.push(id);
      }
    }

    if (newIds.length > 0) {
      for (const id of newIds) {
        toast.info(`Novo pedido #${id}`, { position: 'top-right' });
        increment();
      }
      setHasNewOrders(true);
      const timer = setTimeout(() => setHasNewOrders(false), 1000);
      prevPendingIdsRef.current = currentPendingIds;
      return () => clearTimeout(timer);
    }

    prevPendingIdsRef.current = currentPendingIds;
  }, [orders, increment]);

  return { hasNewOrders };
}
