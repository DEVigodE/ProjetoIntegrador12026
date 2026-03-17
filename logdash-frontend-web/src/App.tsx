import { Routes, Route, Navigate } from 'react-router-dom';
import { useKeycloak } from '@react-keycloak/web';
import PrivateRoute from './routes/PrivateRoute';
import RoleGuard from './routes/RoleGuard';
import MainLayout from './layouts/MainLayout';
import DashboardPage from './features/dashboard/pages/DashboardPage';
import ProductListPage from './features/catalog/pages/ProductListPage';
import ProductFormPage from './features/catalog/pages/ProductFormPage';
import OrdersPage from './features/orders/pages/OrdersPage';
import OrderDetailPage from './features/orders/pages/OrderDetailPage';
import CouriersPage from './features/delivery/pages/CouriersPage';
import DeliveriesPage from './features/delivery/pages/DeliveriesPage';
import ReportsPage from './features/reports/pages/ReportsPage';
import SettingsPage from './features/settings/pages/SettingsPage';

function RootRedirect() {
  const { keycloak } = useKeycloak();
  const roles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];

  if (roles.includes('ADMIN') || roles.includes('OPERATOR')) {
    return <Navigate to="/dashboard" replace />;
  }
  if (roles.includes('DISPATCHER')) {
    return <Navigate to="/deliveries" replace />;
  }
  return <Navigate to="/dashboard" replace />;
}

export default function App() {
  return (
    <Routes>
      <Route element={<PrivateRoute />}>
        <Route element={<MainLayout />}>
          <Route index element={<RootRedirect />} />

          <Route
            path="dashboard"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <DashboardPage />
              </RoleGuard>
            }
          />

          <Route
            path="products"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <ProductListPage />
              </RoleGuard>
            }
          />
          <Route
            path="products/new"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <ProductFormPage />
              </RoleGuard>
            }
          />
          <Route
            path="products/:id/edit"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <ProductFormPage />
              </RoleGuard>
            }
          />

          <Route
            path="orders"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <OrdersPage />
              </RoleGuard>
            }
          />
          <Route
            path="orders/:id"
            element={
              <RoleGuard roles={['ADMIN', 'OPERATOR']}>
                <OrderDetailPage />
              </RoleGuard>
            }
          />

          <Route
            path="couriers"
            element={
              <RoleGuard roles={['ADMIN', 'DISPATCHER']}>
                <CouriersPage />
              </RoleGuard>
            }
          />

          <Route
            path="deliveries"
            element={
              <RoleGuard roles={['ADMIN', 'DISPATCHER']}>
                <DeliveriesPage />
              </RoleGuard>
            }
          />

          <Route
            path="reports"
            element={
              <RoleGuard roles={['ADMIN']}>
                <ReportsPage />
              </RoleGuard>
            }
          />

          <Route
            path="settings"
            element={
              <RoleGuard roles={['ADMIN']}>
                <SettingsPage />
              </RoleGuard>
            }
          />
        </Route>
      </Route>
    </Routes>
  );
}
