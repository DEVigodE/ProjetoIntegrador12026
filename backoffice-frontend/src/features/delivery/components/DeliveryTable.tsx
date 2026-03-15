import Table, { type Column } from '../../../components/ui/Table';
import Badge from '../../../components/ui/Badge';
import Button from '../../../components/ui/Button';
import { getDeliveryStatusLabel, getDeliveryStatusColor } from '../../../utils/deliveryStatusLabel';
import type { Delivery } from '../types/delivery.types';

interface DeliveryTableProps {
  deliveries: Delivery[];
  onAssign: (delivery: Delivery) => void;
}

export default function DeliveryTable({ deliveries, onAssign }: DeliveryTableProps) {
  const columns: Column<Delivery>[] = [
    {
      key: 'orderId',
      header: 'Pedido',
      render: (d) => `#${d.orderId}`,
    },
    {
      key: 'courier',
      header: 'Entregador',
      render: (d) => d.courier?.name ?? 'Nao atribuido',
    },
    {
      key: 'status',
      header: 'Status',
      render: (d) => (
        <Badge variant={getDeliveryStatusColor(d.status)}>
          {getDeliveryStatusLabel(d.status)}
        </Badge>
      ),
    },
    {
      key: 'assignedAt',
      header: 'Atribuido em',
      render: (d) =>
        d.assignedAt
          ? new Date(d.assignedAt).toLocaleString('pt-BR', {
              day: '2-digit',
              month: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
            })
          : '—',
    },
    {
      key: 'actions',
      header: 'Acoes',
      render: (d) => (
        <Button
          size="sm"
          variant="secondary"
          onClick={(e) => {
            e.stopPropagation();
            onAssign(d);
          }}
        >
          {d.courier ? 'Reatribuir' : 'Atribuir'}
        </Button>
      ),
    },
  ];

  return (
    <Table<Delivery>
      columns={columns}
      data={deliveries}
      keyExtractor={(d) => d.id}
    />
  );
}
