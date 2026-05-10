import type { OrderStatus } from '../types/order.types';
import { getStatusLabel } from '../../../utils/orderStatusLabel';

interface OrderTimelineProps {
  currentStatus: OrderStatus;
}

const LIFECYCLE: OrderStatus[] = [
  'PENDING',
  'ACCEPTED',
  'PREPARING',
  'READY',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
];

export default function OrderTimeline({ currentStatus }: OrderTimelineProps) {
  const isCancelled = currentStatus === 'CANCELLED';
  const currentIndex = LIFECYCLE.indexOf(currentStatus);

  const steps = isCancelled
    ? [...LIFECYCLE.slice(0, currentIndex >= 0 ? currentIndex : 0), 'CANCELLED' as OrderStatus]
    : LIFECYCLE;

  return (
    <div className="space-y-0">
      {steps.map((status, index) => {
        let state: 'completed' | 'current' | 'future' | 'cancelled';

        if (isCancelled && status === 'CANCELLED') {
          state = 'cancelled';
        } else if (isCancelled) {
          state = 'completed';
        } else if (index < currentIndex) {
          state = 'completed';
        } else if (index === currentIndex) {
          state = 'current';
        } else {
          state = 'future';
        }

        return (
          <div key={status} className="flex items-start gap-3">
            <div className="flex flex-col items-center">
              <div
                className={`flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold ${
                  state === 'completed'
                    ? 'bg-green-500 text-white'
                    : state === 'current'
                      ? 'bg-orange-500 text-white ring-2 ring-orange-200'
                      : state === 'cancelled'
                        ? 'bg-red-500 text-white'
                        : 'bg-gray-200 text-gray-400'
                }`}
              >
                {state === 'completed' ? (
                  <svg className="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                ) : state === 'cancelled' ? (
                  <svg className="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                ) : (
                  <span>{index + 1}</span>
                )}
              </div>
              {index < steps.length - 1 && (
                <div
                  className={`h-6 w-0.5 ${
                    state === 'completed' || state === 'current'
                      ? 'bg-green-300'
                      : 'bg-gray-200'
                  }`}
                />
              )}
            </div>
            <div className="pb-4">
              <p
                className={`text-sm font-medium ${
                  state === 'future' ? 'text-gray-400' : 'text-gray-900'
                }`}
              >
                {getStatusLabel(status)}
              </p>
            </div>
          </div>
        );
      })}
    </div>
  );
}
