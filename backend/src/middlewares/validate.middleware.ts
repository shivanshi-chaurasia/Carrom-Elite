import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { ApiError } from '../utils/api-error';

export interface ValidationSchemas {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export function validate(schemas: ValidationSchemas) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      const errors: string[] = [];

      if (schemas.body) {
        const result = schemas.body.safeParse(req.body);
        if (!result.success) {
          errors.push(
            ...result.error.errors.map(
              (e) => `body.${e.path.join('.')}: ${e.message}`,
            ),
          );
        } else {
          req.body = result.data;
        }
      }

      if (schemas.query) {
        const result = schemas.query.safeParse(req.query);
        if (!result.success) {
          errors.push(
            ...result.error.errors.map(
              (e) => `query.${e.path.join('.')}: ${e.message}`,
            ),
          );
        } else {
          req.query = result.data;
        }
      }

      if (schemas.params) {
        const result = schemas.params.safeParse(req.params);
        if (!result.success) {
          errors.push(
            ...result.error.errors.map(
              (e) => `params.${e.path.join('.')}: ${e.message}`,
            ),
          );
        } else {
          req.params = result.data;
        }
      }

      if (errors.length > 0) {
        throw ApiError.validation(errors);
      }

      next();
    } catch (error) {
      if (error instanceof ApiError) {
        next(error);
        return;
      }
      if (error instanceof ZodError) {
        const errors = error.errors.map(
          (e) => `${e.path.join('.')}: ${e.message}`,
        );
        next(ApiError.validation(errors));
        return;
      }
      next(error);
    }
  };
}
