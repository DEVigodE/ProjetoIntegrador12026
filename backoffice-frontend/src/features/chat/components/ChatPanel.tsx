import { useMemo, useEffect } from 'react';
import Spinner from '../../../components/ui/Spinner';
import MessageList from './MessageList';
import MessageInput from './MessageInput';
import { useChat } from '../hooks/useChat';
import { useChatWebSocket } from '../hooks/useChatWebSocket';
import { useChatNotificationStore } from '../../../store/chatNotificationStore';
import type { MessageResponse } from '../types/chat.types';

interface ChatPanelProps {
  orderId: number;
}

export default function ChatPanel({ orderId }: ChatPanelProps) {
  const { data: history, isLoading } = useChat(orderId);
  const { messages: wsMessages, sendMessage } = useChatWebSocket(orderId);
  const clearNotifications = useChatNotificationStore((s) => s.clear);

  useEffect(() => {
    clearNotifications();
  }, [clearNotifications]);

  const allMessages = useMemo(() => {
    const historyMessages = history ?? [];
    const seen = new Set<number>(historyMessages.map((m) => m.id));
    const deduplicated: MessageResponse[] = [...historyMessages];
    for (const msg of wsMessages) {
      if (!seen.has(msg.id)) {
        seen.add(msg.id);
        deduplicated.push(msg);
      }
    }
    return deduplicated;
  }, [history, wsMessages]);

  return (
    <div className="flex h-80 flex-col rounded-lg border border-gray-200 bg-white">
      <div className="border-b px-3 py-2">
        <h4 className="text-sm font-semibold text-gray-700">Chat</h4>
      </div>

      {isLoading ? (
        <div className="flex flex-1 items-center justify-center">
          <Spinner />
        </div>
      ) : (
        <MessageList messages={allMessages} />
      )}

      <MessageInput onSend={sendMessage} />
    </div>
  );
}
