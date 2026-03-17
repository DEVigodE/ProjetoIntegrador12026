export interface Category {
  id: number;
  name: string;
  description?: string;
  active: boolean;
}

export interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  imageUrl?: string;
  available: boolean;
  stockQuantity: number;
  minStockAlert: number;
  categoryId: number | null;
  categoryName: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface ProductFilters {
  name?: string;
  categoryId?: number;
  available?: boolean;
}

export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
}
