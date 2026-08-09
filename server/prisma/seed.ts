import { PrismaPg } from '@prisma/adapter-pg';
import * as fs from 'fs';
import { PrismaClient } from '@prisma/client';
import * as path from 'path';

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Seeding database...');

  // 1. Run seed_roles.sql
  const sqlFilePath = path.join(__dirname, 'seed_roles.sql');
  const sql = fs.readFileSync(sqlFilePath, 'utf8');
  await prisma.$executeRawUnsafe(sql);
  console.log('Roles seeded from seed_roles.sql.');

  // 2. Create an admin user with phone number 1234567890
  const adminPhone = '1234567890';

  await prisma.$executeRawUnsafe(`
    INSERT INTO "User" ("id", "phoneNumber", "isActive", "createdAt")
    VALUES (gen_random_uuid()::text, '${adminPhone}', true, NOW())
    ON CONFLICT ("phoneNumber") DO NOTHING;
  `);

  const users: any[] = await prisma.$queryRawUnsafe(`
    SELECT "id" FROM "User" WHERE "phoneNumber" = '${adminPhone}';
  `);
  const userId = users[0].id;

  await prisma.$executeRawUnsafe(`
    INSERT INTO "Profile" ("id", "phoneNumber", "fullName", "isClaimed", "userId", "isActive", "createdAt")
    VALUES (gen_random_uuid()::text, '${adminPhone}', 'System Admin', true, '${userId}', true, NOW())
    ON CONFLICT ("phoneNumber") DO UPDATE SET "userId" = '${userId}';
  `);

  console.log(`Ensured user with phone ${adminPhone} exists. User ID: ${userId}`);

  // 3. Assign admin_staff (4) and admin (5) roles to the user
  const rolesToAssign = [4, 5];

  for (const roleId of rolesToAssign) {
    const existingRole: any[] = await prisma.$queryRawUnsafe(`
      SELECT "id" FROM "UserRole"
      WHERE "userId" = '${userId}' AND "roleId" = ${roleId} AND "gymId" IS NULL;
    `);

    if (existingRole.length === 0) {
      await prisma.$executeRawUnsafe(`
        INSERT INTO "UserRole" ("id", "userId", "roleId", "gymId", "assignedAt")
        VALUES (gen_random_uuid()::text, '${userId}', ${roleId}, NULL, NOW());
      `);
      console.log(`Assigned role ID ${roleId} to the admin user.`);
    } else {
      console.log(`Role ID ${roleId} already assigned to the admin user.`);
    }
  }

  console.log('Database seeding completed successfully.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
