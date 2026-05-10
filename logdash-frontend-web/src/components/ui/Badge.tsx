import { type ReactNode } from 'react';

interface BadgeProps {
  variant: 'green' | 'yellow' | 'blue' | 'red' | 'gray';
  children: ReactNode;
}

const variantClasses: Record<BadgeProps['variant'], string> = {
  green: 'bg-emerald-50 text-emerald-700 border border-emerald-200/70',
  yellow: 'bg-amber-50 text-amber-700 border border-amber-200/70',
  blue: 'bg-sky-50 text-sky-700 border border-sky-200/70',
  red: 'bg-rose-50 text-rose-700 border border-rose-200/70',
  gray: 'bg-gray-50 text-gray-600 border border-gray-200/70',
};

export default function Badge({ variant, children }: BadgeProps) {
  return (
    <span
      className={`inline-flex items-center rounded-md px-2.5 py-1 text-[11px] font-semibold leading-none ${variantClasses[variant]}`}
    >
      {children}
    </span>
  );
}
