import { v2 as cloudinary } from 'cloudinary';
import { UploadApiResponse, UploadApiOptions } from 'cloudinary';
import { config } from '../config';
import { logger } from '../config/logger';
import { ApiError } from '../utils/api-error';

export class CloudinaryService {
  async uploadFile(
    file: Express.Multer.File,
    folder?: string,
  ): Promise<UploadApiResponse> {
    try {
      const options: UploadApiOptions = {
        folder: folder || config.cloudinary.folder,
        resource_type: 'auto',
        quality: 'auto',
        fetch_format: 'auto',
      };

      if (file.buffer) {
        return new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            options,
            (error, result) => {
              if (error) reject(error);
              else resolve(result!);
            },
          );
          stream.end(file.buffer);
        });
      }

      const result = await cloudinary.uploader.upload(file.path, options);
      return result;
    } catch (error) {
      logger.error('Cloudinary upload error:', error);
      throw ApiError.internal('File upload failed');
    }
  }

  async uploadMultiple(
    files: Express.Multer.File[],
    folder?: string,
  ): Promise<UploadApiResponse[]> {
    const uploads = files.map((file) => this.uploadFile(file, folder));
    return Promise.all(uploads);
  }

  async deleteFile(publicId: string): Promise<void> {
    try {
      await cloudinary.uploader.destroy(publicId);
    } catch (error) {
      logger.error('Cloudinary delete error:', error);
      throw ApiError.internal('File deletion failed');
    }
  }

  getPublicIdFromUrl(url: string): string {
    const parts = url.split('/');
    const fileWithExtension = parts[parts.length - 1];
    const folder = parts[parts.length - 2];
    const publicId = fileWithExtension.split('.')[0];
    return `${folder}/${publicId}`;
  }
}

export const cloudinaryService = new CloudinaryService();
