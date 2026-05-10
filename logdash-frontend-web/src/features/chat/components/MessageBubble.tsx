import type { MessageResponse } from '../types/chat.types';

interface MessageBubbleProps {
  message: MessageResponse;
  currentUserId: string;
}

const STYLE_MAP: Record<string, {
  bubble: string;
  time: string;
  name: string;
  label: string;
}> = {
  ADMIN: {
    bubble: 'bg-blue-500 text-white',
    time: 'text-blue-100',
    name: 'text-blue-200',
    label: 'Admin',
  },
  OPERATOR: {
    bubble: 'bg-emerald-500 text-white',
    time: 'text-emerald-100',
    name: 'text-emerald-200',
    label: 'Operador',
  },
  STORE: {
    bubble: 'bg-slate-600 text-white',
    time: 'text-slate-300',
    name: 'text-slate-300',
    label: 'Loja',
  },
  DISPATCHER: {
    bubble: 'bg-violet-500 text-white',
    time: 'text-violet-100',
    name: 'text-violet-200',
    label: 'Despachante',
  },
  COURIER: {
    bubble: 'bg-rose-500 text-white',
    time: 'text-rose-100',
    name: 'text-rose-200',
    label: 'Entregador',
  },
  CUSTOMER: {
    bubble: 'bg-orange-400 text-white',
    time: 'text-orange-100',
    name: 'text-orange-200',
    label: 'Cliente',
  },
  SYSTEM: {
    bubble: 'bg-gray-200 text-gray-600 italic',
    time: 'text-gray-400',
    name: 'text-gray-400',
    label: 'Sistema',
  },
};

const DEFAULT_STYLE = STYLE_MAP.SYSTEM;

function formatTime(isoDate: string): string {
  const date = new Date(isoDate);
  return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
}

export default function MessageBubble({ message, currentUserId }: MessageBubbleProps) {
  const style = STYLE_MAP[message.senderType] ?? DEFAULT_STYLE;
  const isSystem = message.senderType === 'SYSTEM';
  const isMine = message.senderId === currentUserId;
  const align = isSystem ? 'justify-center' : isMine ? 'justify-end' : 'justify-start';

  return (
    <div className={`flex ${align}`}>
      <div className={`max-w-[75%] rounded-xl px-3 py-2 ${style.bubble}`}>
        {!isSystem && (
          <p className={`text-xs font-semibold ${style.name}`}>
            {message.senderId} · {style.label}
          </p>
        )}
        <p className="text-sm whitespace-pre-wrap">{message.content}</p>
        <p className={`mt-0.5 text-xs ${style.time}`}>
          {formatTime(message.sentAt)}
        </p>
      </div>
    </div>
  );
}
