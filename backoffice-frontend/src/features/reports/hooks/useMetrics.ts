import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { SalesReportData } from '../types/report.types';

export function useMetrics() {
  return useQuery<SalesReportData>({
    queryKey: ['metrics'],
    queryFn: async () => {
      const { data } = await api.get<SalesReportData>('/api/reports/metrics');
      return data;
    },
  });
}
