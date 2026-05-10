import { useState } from 'react';
import Button from '../../../components/ui/Button';

interface DateRangePickerProps {
  defaultStartDate: string;
  defaultEndDate: string;
  onFilter: (startDate: string, endDate: string) => void;
}

export default function DateRangePicker({
  defaultStartDate,
  defaultEndDate,
  onFilter,
}: DateRangePickerProps) {
  const [startDate, setStartDate] = useState(defaultStartDate);
  const [endDate, setEndDate] = useState(defaultEndDate);

  function handleFilter() {
    if (startDate && endDate) {
      onFilter(startDate, endDate);
    }
  }

  return (
    <div className="flex items-end gap-4">
      <div>
        <label htmlFor="startDate" className="mb-1 block text-xs font-semibold uppercase tracking-wide text-gray-500">
          Data Inicio
        </label>
        <input
          id="startDate"
          type="date"
          value={startDate}
          onChange={(e) => setStartDate(e.target.value)}
          className="rounded-lg border border-gray-200/80 px-3 py-2 text-sm text-gray-900 shadow-[0_10px_24px_-18px_rgba(15,23,42,0.35)] focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-300/70"
        />
      </div>
      <div>
        <label htmlFor="endDate" className="mb-1 block text-xs font-semibold uppercase tracking-wide text-gray-500">
          Data Fim
        </label>
        <input
          id="endDate"
          type="date"
          value={endDate}
          onChange={(e) => setEndDate(e.target.value)}
          className="rounded-lg border border-gray-200/80 px-3 py-2 text-sm text-gray-900 shadow-[0_10px_24px_-18px_rgba(15,23,42,0.35)] focus:border-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-300/70"
        />
      </div>
      <Button onClick={handleFilter}>Filtrar</Button>
    </div>
  );
}
