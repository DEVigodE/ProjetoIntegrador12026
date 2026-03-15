import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { MessageResponse } from '../types/chat.types';

export function useChat(orderId: number | undefined) {
  return useQuery<MessageResponse[]>({
    queryKey: ['chat', orderId],
    queryFn: async () => {
      const { data } = await api.get<MessageResponse[]>(
        `/api/chat/${orderId}/messages`
      );
      return data;
    },
    enabled: !!orderId,
    refetchOnMount: 'always',
  });
}
