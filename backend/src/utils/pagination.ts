import { PaginationMeta, PaginationParams } from '../interfaces/response.interface';

export function getPaginationParams(query: PaginationParams): Required<PaginationParams> {
  const page = Math.max(1, Number(query.page) || 1);
  const limit = Math.min(100, Math.max(1, Number(query.limit) || 20));
  const sortBy = query.sortBy || 'createdAt';
  const sortOrder = (query.sortOrder === 'asc' ? 'asc' : 'desc') as 'asc' | 'desc';
  const search = query.search || '';
  return { page, limit, sortBy, sortOrder, search };
}

export function getPaginationMeta(
  totalItems: number,
  page: number,
  limit: number,
): PaginationMeta {
  const totalPages = Math.ceil(totalItems / limit);
  return {
    page,
    limit,
    totalItems,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1,
  };
}

export function getPrismaPagination(page: number, limit: number) {
  return {
    skip: (page - 1) * limit,
    take: limit,
  };
}
