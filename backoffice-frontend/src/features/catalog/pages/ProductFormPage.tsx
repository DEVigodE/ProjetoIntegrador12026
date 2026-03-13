import { useParams } from 'react-router-dom';
import PageHeader from '../../../components/layout/PageHeader';

export default function ProductFormPage() {
  const { id } = useParams();
  const title = id ? 'Editar Produto' : 'Novo Produto';

  return (
    <PageHeader
      title={title}
      breadcrumbs={[{ label: 'Produtos' }, { label: title }]}
    />
  );
}
