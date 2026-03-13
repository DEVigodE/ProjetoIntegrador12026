import { create } from 'zustand';

interface OrderNotificationStore {
  pendingCount: number;
  setPendingCount: (count: number) => void;
  increment: () => void;
  clear: () => void;
}

export const useOrderNotificationStore = create<OrderNotificationStore>((set) => ({
  pendingCount: 0,
  setPendingCount: (count) => set({ pendingCount: count }),
  increment: () => set((s) => ({ pendingCount: s.pendingCount + 1 })),
  clear: () => set({ pendingCount: 0 }),
}));
