import { Component, useMemo, useEffect } from 'react';
import type { ReactNode } from 'react';
import { useKeycloak } from '@react-keycloak/web';
import Spinner from '../../../components/ui/Spinner';
import MessageList from './MessageList';
import MessageInput from './MessageInput';
import { useChat } from '../hooks/useChat';
import { useChatWebSocket } from '../hooks/useChatWebSocket';
import { useChatNotificationStore } from '../../../store/chatNotificationStore';
import type { MessageResponse } from '../types/chat.types';

class ChatErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex h-80 flex-col items-center justify-center rounded-lg border border-gray-200 bg-white text-sm text-gray-500">
          <p>Não foi possível carregar o chat.</p>
          <button
            className="mt-2 text-xs text-primary-500 hover:underline"
            onClick={() => this.setState({ hasError: false })}
          >
            Tentar novamente
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

interface ChatPanelProps {
  orderId: number;
}

export default function ChatPanel({ orderId }: ChatPanelProps) {
  const { keycloak } = useKeycloak();
  const { data: history, isLoading } = useChat(orderId);
  const { messages: wsMessages, sendMessage } = useChatWebSocket(orderId);
  const clearNotifications = useChatNotificationStore((s) => s.clear);
  const currentUserId =
    keycloak.tokenParsed?.preferred_username ??
    keycloak.tokenParsed?.sub ??
    '';

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
    <ChatErrorBoundary>
      <div className="flex h-80 flex-col rounded-lg border border-gray-200 bg-white">
        <div className="border-b px-3 py-2">
          <h4 className="text-sm font-semibold text-gray-700">Chat</h4>
        </div>

        {isLoading ? (
          <div className="flex flex-1 items-center justify-center">
            <Spinner />
          </div>
        ) : (
          <MessageList messages={allMessages} currentUserId={currentUserId} />
        )}

        <MessageInput onSend={sendMessage} />
      </div>
    </ChatErrorBoundary>
  );
}
