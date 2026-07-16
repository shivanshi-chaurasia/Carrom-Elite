import { PrismaClient, UserRole } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  const hashedPassword = await bcrypt.hash('Admin@123', 12);

  // Create super admin
  const superAdmin = await prisma.user.upsert({
    where: { email: 'admin@carromlottery.com' },
    update: {},
    create: {
      username: 'superadmin',
      email: 'admin@carromlottery.com',
      password: hashedPassword,
      role: UserRole.SUPER_ADMIN,
      isEmailVerified: true,
      referralCode: 'ADMIN001',
    },
  });

  await prisma.admin.upsert({
    where: { userId: superAdmin.id },
    update: {},
    create: {
      userId: superAdmin.id,
      role: UserRole.SUPER_ADMIN,
      isSuperAdmin: true,
    },
  });

  // Create settings for super admin
  await prisma.settings.upsert({
    where: { userId: superAdmin.id },
    update: {},
    create: {
      userId: superAdmin.id,
    },
  });

  // Create wallet for super admin
  await prisma.wallet.upsert({
    where: { userId: superAdmin.id },
    update: {},
    create: {
      userId: superAdmin.id,
      balance: 0,
    },
  });

  console.log('Seed completed successfully');
}

main()
  .catch((e) => {
    console.error('Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
