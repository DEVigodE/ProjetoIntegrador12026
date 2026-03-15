import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import type { Courier } from '../types/delivery.types';

const courierSchema = z.object({
  name: z.string().min(1, 'Nome e obrigatorio'),
  phone: z.string().min(1, 'Telefone e obrigatorio'),
  email: z.string().email('Email invalido').optional().or(z.literal('')),
  vehicleType: z.string().optional(),
  vehiclePlate: z.string().optional(),
});

export type CourierFormData = z.infer<typeof courierSchema>;

interface CourierFormProps {
  courier?: Courier;
  onSubmit: (data: CourierFormData) => void;
  onCancel: () => void;
  isSubmitting: boolean;
}

export default function CourierForm({ courier, onSubmit, onCancel, isSubmitting }: CourierFormProps) {
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<CourierFormData>({
    resolver: zodResolver(courierSchema),
    defaultValues: {
      name: '',
      phone: '',
      email: '',
      vehicleType: '',
      vehiclePlate: '',
    },
  });

  useEffect(() => {
    if (courier) {
      reset({
        name: courier.name,
        phone: courier.phone,
        email: courier.email ?? '',
        vehicleType: courier.vehicleType ?? '',
        vehiclePlate: courier.vehiclePlate ?? '',
      });
    }
  }, [courier, reset]);

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <Input
        label="Nome"
        placeholder="Nome do entregador"
        error={errors.name?.message}
        {...register('name')}
      />
      <Input
        label="Telefone"
        placeholder="(11) 99999-9999"
        error={errors.phone?.message}
        {...register('phone')}
      />
      <Input
        label="Email"
        placeholder="email@exemplo.com (opcional)"
        error={errors.email?.message}
        {...register('email')}
      />
      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Tipo de Veiculo"
          placeholder="Moto, Bicicleta..."
          {...register('vehicleType')}
        />
        <Input
          label="Placa"
          placeholder="ABC-1234"
          {...register('vehiclePlate')}
        />
      </div>
      <div className="flex justify-end gap-3">
        <Button variant="secondary" type="button" onClick={onCancel} disabled={isSubmitting}>
          Cancelar
        </Button>
        <Button type="submit" loading={isSubmitting}>
          Salvar
        </Button>
      </div>
    </form>
  );
}
