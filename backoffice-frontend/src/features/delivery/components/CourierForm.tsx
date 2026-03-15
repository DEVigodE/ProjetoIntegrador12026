import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import type { Courier } from '../types/delivery.types';

function formatPlate(value: string): string {
  const clean = value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 7);
  if (clean.length <= 3) return clean;
  return `${clean.slice(0, 3)}-${clean.slice(3)}`;
}

function formatPhone(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 11);
  if (digits.length <= 2) return digits.length ? `(${digits}` : '';
  if (digits.length <= 6) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`;
  if (digits.length <= 10) return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`;
  return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
}

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
  onToggleActive?: (courier: Courier) => void;
  canToggleActive?: boolean;
  isSubmitting: boolean;
}

export default function CourierForm({ courier, onSubmit, onCancel, onToggleActive, canToggleActive = false, isSubmitting }: CourierFormProps) {
  const {
    register,
    handleSubmit,
    reset,
    setValue,
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
        onChange={(e) => setValue('phone', formatPhone(e.target.value), { shouldValidate: true })}
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
          onChange={(e) => setValue('vehiclePlate', formatPlate(e.target.value), { shouldValidate: true })}
        />
      </div>
      <div className="flex justify-between gap-3">
        {courier && canToggleActive && onToggleActive && (
          <Button
            type="button"
            variant={courier.active ? 'danger' : 'success'}
            onClick={() => onToggleActive(courier)}
            disabled={isSubmitting}
            aria-label={courier.active ? 'Desativar entregador' : 'Ativar entregador'}
          >
            {courier.active ? 'Desativar' : 'Ativar'}
          </Button>
        )}
        <div className="flex gap-3 ml-auto">
          <Button variant="secondary" type="button" onClick={onCancel} disabled={isSubmitting}>
            Cancelar
          </Button>
          <Button type="submit" loading={isSubmitting}>
            Salvar
          </Button>
        </div>
      </div>
    </form>
  );
}
