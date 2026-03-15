export type SenderType = 'STORE' | 'CUSTOMER' | 'COURIER' | 'SYSTEM';

export interface MessageResponse {
  id: number;
  orderId: number;
  senderId: string;
  senderType: SenderType;
  content: string;
  sentAt: string;
  readAt: string | null;
}
