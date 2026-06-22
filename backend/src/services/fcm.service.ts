import admin from 'firebase-admin';
import { logger } from '../config/logger';

interface PushNotificationPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

interface MulticastPayload {
  tokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}

export class FcmService {
  async sendPushNotification(payload: PushNotificationPayload): Promise<string> {
    try {
      const message: admin.messaging.Message = {
        token: payload.token,
        notification: {
          title: payload.title,
          body: payload.body,
          imageUrl: payload.imageUrl,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'default',
            priority: 'high',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              contentAvailable: true,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      logger.info(`Push notification sent: ${response}`);
      return response;
    } catch (error) {
      logger.error('Push notification error:', error);
      throw error;
    }
  }

  async sendMulticast(payload: MulticastPayload): Promise<admin.messaging.BatchResponse> {
    try {
      const message: admin.messaging.MulticastMessage = {
        tokens: payload.tokens,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data,
        android: {
          priority: 'high',
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      logger.info(
        `Multicast sent: Success=${response.successCount}, Failure=${response.failureCount}`,
      );

      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            logger.warn(
              `Failed to send to token ${idx}: ${resp.error?.message}`,
            );
          }
        });
      }

      return response;
    } catch (error) {
      logger.error('Multicast push error:', error);
      throw error;
    }
  }

  async sendToTopic(topic: string, payload: Omit<PushNotificationPayload, 'token'>): Promise<string> {
    try {
      const message: admin.messaging.Message = {
        topic,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data,
      };

      const response = await admin.messaging().send(message);
      logger.info(`Topic message sent to ${topic}: ${response}`);
      return response;
    } catch (error) {
      logger.error('Topic push error:', error);
      throw error;
    }
  }

  async subscribeToTopic(tokens: string[], topic: string): Promise<void> {
    try {
      await admin.messaging().subscribeToTopic(tokens, topic);
      logger.info(`Subscribed ${tokens.length} devices to topic: ${topic}`);
    } catch (error) {
      logger.error('Topic subscription error:', error);
      throw error;
    }
  }

  async unsubscribeFromTopic(tokens: string[], topic: string): Promise<void> {
    try {
      await admin.messaging().unsubscribeFromTopic(tokens, topic);
      logger.info(`Unsubscribed ${tokens.length} devices from topic: ${topic}`);
    } catch (error) {
      logger.error('Topic unsubscription error:', error);
      throw error;
    }
  }
}

export const fcmService = new FcmService();
