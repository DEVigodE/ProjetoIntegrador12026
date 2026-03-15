## 1. Hook de Deteccao

- [x] 1.1 Criar `features/orders/hooks/useOrderNotifications.ts` com deteccao de novos pedidos PENDING, toast e integracao com orderNotificationStore

## 2. Integracao nos Componentes

- [x] 2.1 Integrar `useOrderNotifications` e `AudioAlert` no OrdersPanel.tsx
- [x] 2.2 Adicionar `orderNotificationStore.clear()` no useEffect de montagem do OrdersPage.tsx

## 3. Verificacao

- [x] 3.1 Verificar compilacao TypeScript sem erros (npx tsc --noEmit)
