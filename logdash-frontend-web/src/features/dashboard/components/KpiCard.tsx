import { type ReactNode } from 'react';

interface KpiCardProps {
  title: string;
  value: string | number;
  icon?: ReactNode;
  subtitle?: string;
}

export default function KpiCard({ title, value, icon, subtitle }: KpiCardProps) {
  return (
    <div className="rounded-xl border border-gray-200/70 bg-gradient-to-br from-white via-white to-orange-50/30 p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="flex items-center justify-between">
        <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">{title}</p>
        {icon && <div className="text-orange-500">{icon}</div>}
      </div>
      <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
      {subtitle && <p className="mt-1 text-sm text-gray-600">{subtitle}</p>}
    </div>
  );
}
