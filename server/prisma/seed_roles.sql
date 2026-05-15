-- Insert the 5 base roles.
-- Using integer IDs 1, 2, 3, 4, 5 so they map cleanly to the Dart integer enum.
INSERT INTO "Role" ("id", "name", "description", "isActive", "isSystem", "createdAt")
VALUES 
  (1, 'member', 'Standard gym member', true, true, NOW()),
  (2, 'staff', 'Gym staff member', true, true, NOW()),
  (5, 'admin', 'Gym administrator', true, true, NOW()),
  (3, 'owner', 'Gym owner', true, true, NOW()),
  (4, 'admin_staff', 'Platform administrator staff', true, true, NOW())
ON CONFLICT ("name") DO UPDATE SET "id" = EXCLUDED."id";

-- Assign the 'member' role (id 1) to all existing users who do not already have it.
-- This uses PostgreSQL's gen_random_uuid() to generate the UserRole primary key.
INSERT INTO "UserRole" ("id", "userId", "roleId", "gymId", "assignedAt", "assignedBy")
SELECT 
  gen_random_uuid()::text, 
  "id", 
  1, 
  NULL, 
  NOW(), 
  'system_migration'
FROM "User" u
WHERE NOT EXISTS (
  SELECT 1 
  FROM "UserRole" ur 
  WHERE ur."userId" = u."id" AND ur."roleId" = 1
);
