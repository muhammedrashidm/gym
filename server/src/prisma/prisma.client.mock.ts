export enum Sex {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  OTHER = 'OTHER',
}

export enum ExpLevel {
  BEGINNER = 'BEGINNER',
  INTERMEDIATE = 'INTERMEDIATE',
  PRO = 'PRO',
}

export enum PlanType {
  MONTHLY = 'MONTHLY',
  ANNUAL = 'ANNUAL',
  CLASS = 'CLASS',
  PUNCH_CARD = 'PUNCH_CARD',
}

export enum MembershipStatus {
  PAID = 'PAID',
  UNPAID = 'UNPAID',
  ACTIVE_KINETIC = 'ACTIVE_KINETIC',
}

export class PrismaClient {
  constructor() {}
  async $connect() {}
  async $disconnect() {}
}
