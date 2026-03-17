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
        <label htmlFor="startDate" className="block text-sm font-medium text-gray-800 mb-1">
          Data Inicio
        </label>
        <input
          id="startDate"
          type="date"
          value={startDate}
          onChange={(e) => setStartDate(e.target.value)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
        />
      </div>
      <div>
        <label htmlFor="endDate" className="block text-sm font-medium text-gray-800 mb-1">
          Data Fim
        </label>
        <input
          id="endDate"
          type="date"
          value={endDate}
          onChange={(e) => setEndDate(e.target.value)}
          className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
        />
      </div>
      <Button onClick={handleFilter}>Filtrar</Button>
    </div>
  );
}
