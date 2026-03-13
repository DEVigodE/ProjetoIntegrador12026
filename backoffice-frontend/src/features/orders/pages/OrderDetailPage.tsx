import PageHeader from '../../../components/layout/PageHeader';

export default function OrderDetailPage() {
  return (
    <PageHeader
      title="Detalhes do Pedido"
      breadcrumbs={[{ label: 'Pedidos' }, { label: 'Detalhes' }]}
    />
  );
}
