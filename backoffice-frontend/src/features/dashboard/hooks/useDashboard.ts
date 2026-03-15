import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { DashboardData } from './dashboard.types';

export function useDashboard() {
  return useQuery<DashboardData>({
    queryKey: ['dashboard'],
    queryFn: async () => {
      const { data } = await api.get<DashboardData>('/api/reports/dashboard');
      return data;
    },
  });
}
