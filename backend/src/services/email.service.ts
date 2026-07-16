import nodemailer from 'nodemailer';
import { config } from '../config';
import { logger } from '../config/logger';

interface EmailOptions {
  to: string;
  subject: string;
  text?: string;
  html?: string;
}

export class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: config.smtp.host,
      port: config.smtp.port,
      secure: config.smtp.secure,
      auth: {
        user: config.smtp.user,
        pass: config.smtp.pass,
      },
    });
  }

  async sendEmail(options: EmailOptions): Promise<void> {
    try {
      const mailOptions: nodemailer.SendMailOptions = {
        from: `"Carrom Lottery" <${config.smtp.from}>`,
        to: options.to,
        subject: options.subject,
        text: options.text,
        html: options.html,
      };

      const info = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent successfully to ${options.to}: ${info.messageId}`);
    } catch (error) {
      logger.error(`Failed to send email to ${options.to}:`, error);
      throw error;
    }
  }

  async sendOtpEmail(email: string, otp: string): Promise<void> {
    await this.sendEmail({
      to: email,
      subject: 'Your OTP Code - Carrom Lottery',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Email Verification</h2>
          <p>Your OTP code is:</p>
          <h1 style="color: #4F46E5; font-size: 36px; letter-spacing: 5px; text-align: center;">${otp}</h1>
          <p>This code will expire in 10 minutes.</p>
          <p>If you did not request this, please ignore this email.</p>
        </div>
      `,
    });
  }

  async sendWelcomeEmail(email: string, username: string): Promise<void> {
    await this.sendEmail({
      to: email,
      subject: 'Welcome to Carrom Lottery!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Welcome, ${username}!</h2>
          <p>Thank you for joining Carrom Lottery. Get ready for an exciting gaming experience!</p>
          <p>Play carrom matches, participate in lotteries, and win amazing prizes.</p>
          <p>Complete your profile and KYC to start playing.</p>
        </div>
      `,
    });
  }

  async sendPasswordResetEmail(email: string, resetToken: string): Promise<void> {
    await this.sendEmail({
      to: email,
      subject: 'Password Reset - Carrom Lottery',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Password Reset</h2>
          <p>Click the link below to reset your password:</p>
          <a href="${resetToken}" style="display: inline-block; padding: 12px 24px; background: #4F46E5; color: white; text-decoration: none; border-radius: 5px;">Reset Password</a>
          <p>This link will expire in 1 hour.</p>
          <p>If you did not request this, please ignore this email.</p>
        </div>
      `,
    });
  }

  async sendWithdrawalOtpEmail(email: string, otp: string, amount: number): Promise<void> {
    await this.sendEmail({
      to: email,
      subject: 'Withdrawal OTP - Carrom Lottery',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Withdrawal Verification</h2>
          <p>You have requested a withdrawal of ₹${amount}.</p>
          <p>Your OTP code is:</p>
          <h1 style="color: #4F46E5; font-size: 36px; letter-spacing: 5px; text-align: center;">${otp}</h1>
          <p>This code will expire in 10 minutes.</p>
          <p>If you did not request this withdrawal, please contact support immediately.</p>
        </div>
      `,
    });
  }
}

export const emailService = new EmailService();
