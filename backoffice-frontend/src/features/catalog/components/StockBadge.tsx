import Badge from '../../../components/ui/Badge';

interface StockBadgeProps {
  stockQuantity: number;
  minStockAlert: number;
}

export default function StockBadge({ stockQuantity, minStockAlert }: StockBadgeProps) {
  const isLow = stockQuantity < minStockAlert;

  return (
    <Badge variant={isLow ? 'red' : 'green'}>
      {stockQuantity} {isLow && '(baixo)'}
    </Badge>
  );
}
