import { create } from 'zustand';

interface ChatNotificationStore {
  unreadCount: number;
  increment: () => void;
  clear: () => void;
}

export const useChatNotificationStore = create<ChatNotificationStore>((set) => ({
  unreadCount: 0,
  increment: () => set((s) => ({ unreadCount: s.unreadCount + 1 })),
  clear: () => set({ unreadCount: 0 }),
}));
