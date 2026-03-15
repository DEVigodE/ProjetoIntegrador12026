import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { SalesReportData } from '../types/report.types';

export function useSalesReport(startDate: string, endDate: string) {
  return useQuery<SalesReportData>({
    queryKey: ['salesReport', startDate, endDate],
    queryFn: async () => {
      const { data } = await api.get<SalesReportData>('/api/reports/sales', {
        params: { startDate, endDate },
      });
      return data;
    },
    enabled: !!startDate && !!endDate,
  });
}
