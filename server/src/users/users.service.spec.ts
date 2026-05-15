import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { Sex, ExpLevel } from '@prisma/client';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { BodyMetricsModel } from './models/body-metrics.model';

describe('UsersService', () => {
  let service: UsersService;
  let prismaService: PrismaService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
    },
    profile: {
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    bodyMetrics: {
      create: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createProfile', () => {
    const userId = 'user-1';
    const phoneNumber = '+1234567890';
    const dto = {
      fullName: 'John Doe',
      age: 30,
      sex: Sex.MALE,
      expLevel: ExpLevel.BEGINNER,
      weight: 80,
      height: 180,
    };

    it('should throw BadRequestException if profile already exists', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: 'existing-id' });

      await expect(service.createProfile(userId, phoneNumber, dto)).rejects.toThrow(BadRequestException);
      expect(mockPrismaService.profile.findUnique).toHaveBeenCalledWith({ where: { userId } });
    });

    it('should create a profile with bodyMetrics if weight and height are provided', async () => {
      const createdProfile = {
        id: 'new-profile',
        userId,
        phoneNumber,
        fullName: dto.fullName,
        age: dto.age,
        sex: dto.sex,
        expLevel: dto.expLevel,
        isKinetic: false,
        isClaimed: true,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        bodyMetrics: [{
          id: 'bm-1',
          weight: 80,
          height: 180,
          muscleMass: null,
          bodyFatPct: null,
          recordedAt: new Date(),
          profileId: 'new-profile',
        }],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      mockPrismaService.profile.create.mockResolvedValueOnce(createdProfile);

      const result = await service.createProfile(userId, phoneNumber, dto);

      expect(mockPrismaService.profile.create).toHaveBeenCalledWith({
        data: {
          fullName: 'John Doe',
          age: 30,
          sex: Sex.MALE,
          expLevel: ExpLevel.BEGINNER,
          userId,
          phoneNumber,
          isClaimed: true,
          bodyMetrics: {
            create: {
              weight: 80,
              height: 180,
              muscleMass: undefined,
              bodyFatPct: undefined,
            },
          },
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.id).toBe('new-profile');
      expect(result.fullName).toBe('John Doe');
      expect(result.bodyMetrics).toHaveLength(1);
      expect(result.bodyMetrics[0]).toBeInstanceOf(BodyMetricsModel);
    });

    it('should create a profile without bodyMetrics if weight or height is missing', async () => {
      const createdProfile = {
        id: 'new-profile',
        userId,
        phoneNumber,
        fullName: 'John Doe',
        age: null,
        sex: null,
        expLevel: null,
        isKinetic: false,
        isClaimed: true,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        bodyMetrics: [],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      mockPrismaService.profile.create.mockResolvedValueOnce(createdProfile);

      const partialDto = { fullName: 'John Doe' };
      const result = await service.createProfile(userId, phoneNumber, partialDto);

      expect(mockPrismaService.profile.create).toHaveBeenCalledWith({
        data: {
          fullName: 'John Doe',
          userId,
          phoneNumber,
          isClaimed: true,
          bodyMetrics: undefined,
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.bodyMetrics).toHaveLength(0);
    });
  });

  describe('updateProfile', () => {
    const userId = 'user-1';
    const dto = { fullName: 'Jane Doe', weight: 65, height: 170 };

    it('should throw NotFoundException if profile does not exist', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      await expect(service.updateProfile(userId, dto)).rejects.toThrow(NotFoundException);
    });

    it('should update profile and create bodyMetrics', async () => {
      const updatedProfile = {
        id: 'profile-1',
        userId,
        phoneNumber: '+1234567890',
        fullName: dto.fullName,
        age: null,
        sex: null,
        expLevel: null,
        isKinetic: false,
        isClaimed: true,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        bodyMetrics: [{
          id: 'bm-2',
          weight: 65,
          height: 170,
          muscleMass: null,
          bodyFatPct: null,
          recordedAt: new Date(),
          profileId: 'profile-1',
        }],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: 'profile-1', userId });
      mockPrismaService.profile.update.mockResolvedValueOnce(updatedProfile);

      const result = await service.updateProfile(userId, dto);

      expect(mockPrismaService.profile.update).toHaveBeenCalledWith({
        where: { userId },
        data: {
          fullName: 'Jane Doe',
          bodyMetrics: {
            create: {
              weight: 65,
              height: 170,
              muscleMass: undefined,
              bodyFatPct: undefined,
            },
          },
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.fullName).toBe('Jane Doe');
    });
  });

  describe('disableProfile', () => {
    const userId = 'user-1';

    it('should throw NotFoundException if profile does not exist', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      await expect(service.disableProfile(userId)).rejects.toThrow(NotFoundException);
    });

    it('should soft delete the profile by setting isActive to false', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: 'profile-1', userId });
      mockPrismaService.profile.update.mockResolvedValueOnce({ id: 'profile-1', isActive: false });

      const result = await service.disableProfile(userId);

      expect(mockPrismaService.profile.update).toHaveBeenCalledWith({
        where: { userId },
        data: { isActive: false },
      });
      expect(result).toBeInstanceOf(DisableProfileModel);
      expect(result.success).toBe(true);
    });
  });

  describe('staffCreateProfile', () => {
    const staffUserId = 'staff-1';
    const gymId = 'gym-1';
    const dto = {
      phoneNumber: '+1999999999',
      fullName: 'Walk In',
    };

    it('should throw BadRequestException if profile with phone number already exists', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: 'existing' });

      await expect(service.staffCreateProfile(gymId, staffUserId, dto)).rejects.toThrow(BadRequestException);
      expect(mockPrismaService.profile.findUnique).toHaveBeenCalledWith({ where: { phoneNumber: dto.phoneNumber } });
    });

    it('should create an unclaimed profile if user does not exist', async () => {
      const createdProfile = {
        id: 'new-profile',
        userId: null,
        phoneNumber: dto.phoneNumber,
        fullName: dto.fullName,
        age: null,
        sex: null,
        expLevel: null,
        isKinetic: false,
        isClaimed: false,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        createdById: staffUserId,
        createdAtGymId: gymId,
        bodyMetrics: [],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null); // Profile phone check
      mockPrismaService.user.findUnique.mockResolvedValueOnce(null); // User phone check
      mockPrismaService.profile.create.mockResolvedValueOnce(createdProfile);

      const result = await service.staffCreateProfile(gymId, staffUserId, dto);

      expect(mockPrismaService.profile.create).toHaveBeenCalledWith({
        data: {
          fullName: 'Walk In',
          phoneNumber: dto.phoneNumber,
          userId: null,
          isClaimed: false,
          createdById: staffUserId,
          createdAtGymId: gymId,
          bodyMetrics: undefined,
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.isClaimed).toBe(false);
      expect(result.userId).toBeNull();
    });

    it('should create a claimed profile and link user if user exists', async () => {
      const createdProfile = {
        id: 'new-profile',
        userId: 'existing-user-id',
        phoneNumber: dto.phoneNumber,
        fullName: dto.fullName,
        age: null,
        sex: null,
        expLevel: null,
        isKinetic: false,
        isClaimed: true,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        createdById: staffUserId,
        createdAtGymId: gymId,
        bodyMetrics: [],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      mockPrismaService.user.findUnique.mockResolvedValueOnce({ id: 'existing-user-id' });
      mockPrismaService.profile.create.mockResolvedValueOnce(createdProfile);

      const result = await service.staffCreateProfile(gymId, staffUserId, dto);

      expect(mockPrismaService.profile.create).toHaveBeenCalledWith({
        data: {
          fullName: 'Walk In',
          phoneNumber: dto.phoneNumber,
          userId: 'existing-user-id',
          isClaimed: true,
          createdById: staffUserId,
          createdAtGymId: gymId,
          bodyMetrics: undefined,
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.isClaimed).toBe(true);
      expect(result.userId).toBe('existing-user-id');
    });
  });

  describe('staffUpdateProfile', () => {
    const profileId = 'profile-1';
    const dto = { fullName: 'Jane Staff Update' };

    it('should throw NotFoundException if profile does not exist', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      await expect(service.staffUpdateProfile(profileId, dto)).rejects.toThrow(NotFoundException);
    });

    it('should update profile using profileId', async () => {
      const updatedProfile = {
        id: profileId,
        userId: 'user-1',
        phoneNumber: '+1234567890',
        fullName: dto.fullName,
        age: null,
        sex: null,
        expLevel: null,
        isKinetic: false,
        isClaimed: true,
        avatarUrl: null,
        isActive: true,
        createdAt: new Date(),
        bodyMetrics: [],
      };
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: profileId });
      mockPrismaService.profile.update.mockResolvedValueOnce(updatedProfile);

      const result = await service.staffUpdateProfile(profileId, dto);

      expect(mockPrismaService.profile.update).toHaveBeenCalledWith({
        where: { id: profileId },
        data: {
          fullName: 'Jane Staff Update',
          bodyMetrics: undefined,
        },
        include: { bodyMetrics: true },
      });
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.fullName).toBe('Jane Staff Update');
    });
  });

  describe('staffDisableProfile', () => {
    const profileId = 'profile-1';

    it('should throw NotFoundException if profile does not exist', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce(null);
      await expect(service.staffDisableProfile(profileId)).rejects.toThrow(NotFoundException);
    });

    it('should soft delete the profile by setting isActive to false', async () => {
      mockPrismaService.profile.findUnique.mockResolvedValueOnce({ id: profileId });
      mockPrismaService.profile.update.mockResolvedValueOnce({ id: profileId, isActive: false });

      const result = await service.staffDisableProfile(profileId);

      expect(mockPrismaService.profile.update).toHaveBeenCalledWith({
        where: { id: profileId },
        data: { isActive: false },
      });
      expect(result).toBeInstanceOf(DisableProfileModel);
      expect(result.success).toBe(true);
    });
  });
});
