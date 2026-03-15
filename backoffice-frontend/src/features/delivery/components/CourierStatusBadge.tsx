import Badge from '../../../components/ui/Badge';
import { getCourierStatusLabel, getCourierStatusColor } from '../../../utils/deliveryStatusLabel';
import type { CourierStatus } from '../types/delivery.types';

interface CourierStatusBadgeProps {
  status: CourierStatus;
}

export default function CourierStatusBadge({ status }: CourierStatusBadgeProps) {
  return (
    <Badge variant={getCourierStatusColor(status)}>
      {getCourierStatusLabel(status)}
    </Badge>
  );
}
