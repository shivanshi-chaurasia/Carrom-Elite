import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config';
import { ApiError } from '../utils/api-error';

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  },
});

const fileFilter = (
  _req: Express.Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback,
) => {
  if (config.upload.allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new ApiError(400, `Invalid file type: ${file.mimetype}. Allowed: ${config.upload.allowedTypes.join(', ')}`));
  }
};

export const upload = multer({
  storage,
  limits: {
    fileSize: config.upload.maxFileSize,
  },
  fileFilter,
});

export const uploadToMemory = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: config.upload.maxFileSize,
  },
  fileFilter,
});
