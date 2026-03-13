import { useEffect, useRef } from 'react';

interface AudioAlertProps {
  play: boolean;
}

export default function AudioAlert({ play }: AudioAlertProps) {
  const prevPlay = useRef(false);

  useEffect(() => {
    if (play && !prevPlay.current) {
      const ctx = new AudioContext();
      const oscillator = ctx.createOscillator();
      const gain = ctx.createGain();

      oscillator.connect(gain);
      gain.connect(ctx.destination);

      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(880, ctx.currentTime);
      oscillator.frequency.setValueAtTime(660, ctx.currentTime + 0.15);

      gain.gain.setValueAtTime(0.3, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);

      oscillator.start(ctx.currentTime);
      oscillator.stop(ctx.currentTime + 0.4);

      oscillator.onended = () => ctx.close();
    }
    prevPlay.current = play;
  }, [play]);

  return null;
}
