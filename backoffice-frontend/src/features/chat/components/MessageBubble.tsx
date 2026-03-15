import type { MessageResponse } from '../types/chat.types';

interface MessageBubbleProps {
  message: MessageResponse;
}

const STYLE_MAP = {
  STORE: {
    align: 'justify-end',
    bubble: 'bg-primary-500 text-white',
    time: 'text-white/70',
  },
  CUSTOMER: {
    align: 'justify-start',
    bubble: 'bg-gray-100 text-gray-900',
    time: 'text-gray-500',
  },
  COURIER: {
    align: 'justify-start',
    bubble: 'bg-blue-100 text-blue-900',
    time: 'text-blue-500',
  },
  SYSTEM: {
    align: 'justify-center',
    bubble: 'bg-gray-200 text-gray-700 italic',
    time: 'text-gray-500',
  },
} as const;

function formatTime(isoDate: string): string {
  const date = new Date(isoDate);
  return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
}

export default function MessageBubble({ message }: MessageBubbleProps) {
  const style = STYLE_MAP[message.senderType];

  return (
    <div className={`flex ${style.align}`}>
      <div className={`max-w-[75%] rounded-lg px-3 py-2 ${style.bubble}`}>
        <p className="text-sm whitespace-pre-wrap">{message.content}</p>
        <p className={`mt-0.5 text-xs ${style.time}`}>
          {formatTime(message.sentAt)}
        </p>
      </div>
    </div>
  );
}
