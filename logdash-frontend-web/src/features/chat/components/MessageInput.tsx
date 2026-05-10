import { useState } from 'react';

interface MessageInputProps {
  onSend: (content: string) => void;
}

export default function MessageInput({ onSend }: MessageInputProps) {
  const [text, setText] = useState('');

  function handleSend() {
    const trimmed = text.trim();
    if (!trimmed) return;
    onSend(trimmed);
    setText('');
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  }

  return (
    <div className="flex gap-2 border-t border-gray-100 bg-gray-50/60 p-3">
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Digite uma mensagem..."
        className="flex-1 rounded-lg border border-gray-200/80 px-3 py-2 text-sm text-gray-900 shadow-[0_10px_24px_-18px_rgba(15,23,42,0.35)] focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-300/70"
        aria-label="Mensagem"
      />
      <button
        type="button"
        onClick={handleSend}
        className="rounded-lg bg-orange-500 px-4 py-2 text-sm font-semibold text-white hover:bg-orange-600 transition-colors"
      >
        Enviar
      </button>
    </div>
  );
}
