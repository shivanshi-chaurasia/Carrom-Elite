import { PrismaClient } from '@prisma/client';
import { prisma } from '../config/database';

type PrismaDelegate = {
  findUnique: (args: any) => Promise<any>;
  findFirst: (args: any) => Promise<any>;
  findMany: (args: any) => Promise<any[]>;
  create: (args: any) => Promise<any>;
  update: (args: any) => Promise<any>;
  delete: (args: any) => Promise<any>;
  count: (args: any) => Promise<number>;
  upsert: (args: any) => Promise<any>;
  updateMany: (args: any) => Promise<{ count: number }>;
};

export class BaseRepository<T, D extends PrismaDelegate> {
  protected prisma: PrismaClient;
  protected delegate: D;

  constructor(delegate: D) {
    this.prisma = prisma;
    this.delegate = delegate;
  }

  async findById(id: string): Promise<T | null> {
    return this.delegate.findUnique({ where: { id } }) as Promise<T | null>;
  }

  async findFirst(where: any): Promise<T | null> {
    return this.delegate.findFirst({ where }) as Promise<T | null>;
  }

  async findMany(params?: {
    where?: any;
    orderBy?: any;
    skip?: number;
    take?: number;
    include?: any;
    select?: any;
  }): Promise<T[]> {
    return this.delegate.findMany(params) as Promise<T[]>;
  }

  async create(data: any): Promise<T> {
    return this.delegate.create({ data }) as Promise<T>;
  }

  async update(id: string, data: any): Promise<T> {
    return this.delegate.update({
      where: { id },
      data,
    }) as Promise<T>;
  }

  async delete(id: string): Promise<T> {
    return this.delegate.delete({ where: { id } }) as Promise<T>;
  }

  async softDelete(id: string): Promise<T> {
    return this.delegate.update({
      where: { id },
      data: { deletedAt: new Date() },
    }) as Promise<T>;
  }

  async count(where?: any): Promise<number> {
    return this.delegate.count({ where }) as Promise<number>;
  }

  async exists(where: any): Promise<boolean> {
    const result = await this.delegate.findFirst({ where });
    return result !== null;
  }

  async upsert(data: any, where: any): Promise<T> {
    return this.delegate.upsert({ where, create: data, update: data }) as Promise<T>;
  }
}
