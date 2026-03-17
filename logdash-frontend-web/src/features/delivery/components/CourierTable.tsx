import Table, { type Column } from '../../../components/ui/Table';
import Badge from '../../../components/ui/Badge';
import Button from '../../../components/ui/Button';
import CourierStatusBadge from './CourierStatusBadge';
import type { Courier } from '../types/delivery.types';

interface CourierTableProps {
  couriers: Courier[];
  onEdit: (courier: Courier) => void;
}

export default function CourierTable({ couriers, onEdit }: CourierTableProps) {
  const columns: Column<Courier>[] = [
    { key: 'name', header: 'Nome', sortable: true },
    { key: 'phone', header: 'Telefone' },
    {
      key: 'vehicleType',
      header: 'Veiculo',
      render: (c) => {
        const vehicle = [c.vehicleType, c.vehiclePlate].filter(Boolean).join(' - ');
        return vehicle || '—';
      },
    },
    {
      key: 'status',
      header: 'Status',
      render: (c) => <CourierStatusBadge status={c.status} />,
    },
    {
      key: 'active',
      header: 'Ativo',
      render: (c) => (
        <Badge variant={c.active ? 'green' : 'gray'}>
          {c.active ? 'Ativo' : 'Inativo'}
        </Badge>
      ),
    },
    {
      key: 'actions',
      header: 'Acoes',
      render: (c) => (
        <Button
          size="sm"
          variant="secondary"
          onClick={(e) => {
            e.stopPropagation();
            onEdit(c);
          }}
        >
          Editar
        </Button>
      ),
    },
  ];

  return (
    <Table<Courier>
      columns={columns}
      data={couriers}
      keyExtractor={(c) => c.id}
    />
  );
}
