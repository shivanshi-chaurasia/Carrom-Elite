export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  meta?: PaginationMeta;
  correlationId?: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  totalItems: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

export interface JwtPayload {
  userId: string;
}

export interface TokenPayload {
  token: string;
}

export interface RequestUser {
  id: string;
  email: string;
  role: string;
  isEmailVerified?: boolean;
  isPhoneVerified?: boolean;
}
