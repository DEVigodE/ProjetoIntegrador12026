import { useEffect, useRef } from 'react';
import MessageBubble from './MessageBubble';
import type { MessageResponse } from '../types/chat.types';

interface MessageListProps {
  messages: MessageResponse[];
  currentUserId: string;
}

export default function MessageList({ messages, currentUserId }: MessageListProps) {
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  if (messages.length === 0) {
    return (
      <div className="flex flex-1 items-center justify-center">
        <p className="text-sm text-gray-400">Nenhuma mensagem ainda</p>
      </div>
    );
  }

  return (
    <div className="flex-1 space-y-2 overflow-y-auto p-3">
      {messages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} currentUserId={currentUserId} />
      ))}
      <div ref={bottomRef} />
    </div>
  );
}
