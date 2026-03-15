export interface TopProduct {
  productId: number;
  productName: string;
  totalQuantitySold: number;
  totalRevenue: number;
}

export interface DashboardData {
  totalOrdersToday: number;
  pendingOrders: number;
  activeDeliveries: number;
  availableCouriers: number;
  revenueToday: number;
  topSellingProducts: TopProduct[];
}
