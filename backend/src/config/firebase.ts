import admin from 'firebase-admin';
import { config } from './index';
import { logger } from './logger';

export function initializeFirebase(): void {
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: config.firebase.projectId,
        privateKey: config.firebase.privateKey.replace(/\\n/g, '\n'),
        clientEmail: config.firebase.clientEmail,
      }),
      databaseURL: config.firebase.databaseURL,
    });
    logger.info('Firebase initialized successfully');
  }
}

export const firebaseMessaging = admin.messaging;
export default admin;
