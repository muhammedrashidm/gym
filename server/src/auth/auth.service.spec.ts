import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import * as crypto from 'crypto';
import { OtpRequestedModel } from './models/otp-requested.model';
import { VerifyOtpResponseModel } from './models/verify-otp-response.model';
import { TokenPairModel } from './models/token-pair.model';
import { LogoutModel } from './models/logout.model';
import { AuthUserModel } from './models/auth-user.model';
import { UserRoleModel } from './models/user-role.model';

describe('AuthService', () => {
  let authService: AuthService;
  let prisma: jest.Mocked<PrismaService>;
  let jwtService: jest.Mocked<JwtService>;
  let config: jest.Mocked<ConfigService>;

  beforeEach(async () => {
    const mockPrismaService = {
      otpRequest: {
        create: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      user: {
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      profile: {
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      role: {
        findUnique: jest.fn(),
      },
      userRole: {
        findFirst: jest.fn(),
        create: jest.fn(),
        findMany: jest.fn(),
      },
      refreshToken: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
    };

    const mockJwtService = {
      sign: jest.fn(),
    };

    const mockConfigService = {
      get: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    prisma = module.get(PrismaService);
    jwtService = module.get(JwtService);
    config = module.get(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(authService).toBeDefined();
  });

  describe('requestOtp', () => {
    it('should create an OTP request and return OtpRequestedModel', async () => {
      config.get.mockReturnValue('development');
      prisma.otpRequest.create.mockResolvedValue({} as any);

      const result = await authService.requestOtp('+1234567890');

      expect(config.get).toHaveBeenCalledWith('NODE_ENV');
      expect(prisma.otpRequest.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            phoneNumber: '+1234567890',
            code: '1234',
          }),
        }),
      );
      expect(result).toBeInstanceOf(OtpRequestedModel);
      expect(result.success).toBe(true);
    });
  });

  describe('verifyOtp', () => {
    it('should throw UnauthorizedException if OTP not found or expired', async () => {
      prisma.otpRequest.findFirst.mockResolvedValue(null);

      await expect(
        authService.verifyOtp('+1234567890', '1234'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException if OTP is wrong in production', async () => {
      config.get.mockReturnValue('production');
      const futureDate = new Date(Date.now() + 100000);
      prisma.otpRequest.findFirst.mockResolvedValue({
        id: 'otp-id',
        phoneNumber: '+1234567890',
        code: '9999',
        expiresAt: futureDate,
        verified: false,
      } as any);

      await expect(
        authService.verifyOtp('+1234567890', '1234'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should verify OTP, create tokens, and return VerifyOtpResponseModel', async () => {
      config.get.mockImplementation((key: string) => {
        if (key === 'NODE_ENV') return 'development';
        if (key === 'REFRESH_TOKEN_EXPIRES_DAYS') return 30;
        return null;
      });

      const futureDate = new Date(Date.now() + 100000);
      prisma.otpRequest.findFirst.mockResolvedValue({
        id: 'otp-id',
        phoneNumber: '+1234567890',
        code: '1234',
        expiresAt: futureDate,
        verified: false,
      } as any);

      prisma.user.findUnique.mockResolvedValue({
        id: 'user-id',
        phoneNumber: '+1234567890',
        isActive: true,
      } as any);

      prisma.profile.findFirst.mockResolvedValue(null); // No unclaimed profile

      prisma.userRole.findMany.mockResolvedValue([]);

      jwtService.sign.mockReturnValue('access-token');

      const result = await authService.verifyOtp('+1234567890', '1234');

      expect(prisma.otpRequest.update).toHaveBeenCalledWith({
        where: { id: 'otp-id' },
        data: { verified: true },
      });
      expect(jwtService.sign).toHaveBeenCalled();
      expect(prisma.refreshToken.create).toHaveBeenCalled();
      expect(result).toBeInstanceOf(VerifyOtpResponseModel);
      expect(result.accessToken).toBe('access-token');
      expect(result.refreshToken).toBeDefined();
      expect(result.user).toBeInstanceOf(AuthUserModel);
      expect(result.user.id).toBe('user-id');
      expect(result.claimedProfile).toBeNull();
    });

    it('should claim unclaimed profile and assign member role when profile exists', async () => {
      config.get.mockImplementation((key: string) => {
        if (key === 'NODE_ENV') return 'development';
        if (key === 'REFRESH_TOKEN_EXPIRES_DAYS') return 30;
        return null;
      });

      const futureDate = new Date(Date.now() + 100000);
      prisma.otpRequest.findFirst.mockResolvedValue({
        id: 'otp-id',
        phoneNumber: '+1234567890',
        code: '1234',
        expiresAt: futureDate,
        verified: false,
      } as any);

      prisma.user.findUnique.mockResolvedValue({
        id: 'user-id',
        phoneNumber: '+1234567890',
        isActive: true,
      } as any);

      const mockProfile = {
        id: 'profile-id',
        userId: null,
        phoneNumber: '+1234567890',
        fullName: 'Test User',
        isClaimed: false,
        createdAtGymId: 'gym-id',
        bodyMetrics: [],
        isKinetic: false,
        isActive: true,
        createdAt: new Date(),
      };
      prisma.profile.findFirst.mockResolvedValue(mockProfile as any);

      prisma.profile.update.mockResolvedValue({
        ...mockProfile,
        userId: 'user-id',
        isClaimed: true,
        bodyMetrics: [],
      } as any);

      prisma.role.findUnique.mockResolvedValue({
        id: 'role-id',
        name: 'member',
        isActive: true,
      } as any);

      prisma.userRole.findFirst.mockResolvedValue(null);
      prisma.userRole.create.mockResolvedValue({} as any);
      prisma.userRole.findMany.mockResolvedValue([
        { role: { id: 'role-id', name: 'member' }, gymId: 'gym-id' },
      ] as any);

      jwtService.sign.mockReturnValue('access-token');

      const result = await authService.verifyOtp('+1234567890', '1234');

      expect(prisma.profile.update).toHaveBeenCalled();
      expect(prisma.userRole.create).toHaveBeenCalled();
      expect(result.claimedProfile).toBeDefined();
      expect(result.user.roles).toHaveLength(1);
      expect(result.user.roles[0].roleName).toBe('member');
    });
  });

  describe('refresh', () => {
    it('should throw UnauthorizedException if token is invalid or revoked', async () => {
      prisma.refreshToken.findUnique.mockResolvedValue(null);

      await expect(authService.refresh('some-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should issue new TokenPairModel if refresh token is valid', async () => {
      const futureDate = new Date(Date.now() + 100000);
      prisma.refreshToken.findUnique.mockResolvedValue({
        id: 'token-id',
        userId: 'user-id',
        isRevoked: false,
        expiresAt: futureDate,
      } as any);

      prisma.user.findUnique.mockResolvedValue({
        id: 'user-id',
        phoneNumber: '+1234567890',
        isActive: true,
      } as any);

      prisma.userRole.findMany.mockResolvedValue([]);
      jwtService.sign.mockReturnValue('new-access-token');

      config.get.mockReturnValue(30); // REFRESH_TOKEN_EXPIRES_DAYS

      const result = await authService.refresh('valid-token');

      expect(prisma.refreshToken.update).toHaveBeenCalledWith({
        where: { id: 'token-id' },
        data: { isRevoked: true },
      });
      expect(jwtService.sign).toHaveBeenCalled();
      expect(result).toBeInstanceOf(TokenPairModel);
      expect(result.accessToken).toBe('new-access-token');
      expect(result.refreshToken).toBeDefined();
    });
  });

  describe('logout', () => {
    it('should revoke refresh token and return LogoutModel', async () => {
      const result = await authService.logout('user-id', 'some-token');

      expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith({
        where: expect.objectContaining({ userId: 'user-id' }),
        data: { isRevoked: true },
      });
      expect(result).toBeInstanceOf(LogoutModel);
      expect(result.success).toBe(true);
    });
  });

  describe('getMe', () => {
    it('should return AuthUserModel with roles', async () => {
      prisma.user.findUnique.mockResolvedValue({
        id: 'user-id',
        phoneNumber: '+1234567890',
        isActive: true,
      } as any);

      prisma.userRole.findMany.mockResolvedValue([
        {
          role: { id: 'role-id', name: 'OWNER' },
          gymId: 'gym-id',
        },
      ] as any);

      const result = await authService.getMe('user-id');

      expect(result).toBeInstanceOf(AuthUserModel);
      expect(result.id).toBe('user-id');
      expect(result.phoneNumber).toBe('+1234567890');
      expect(result.isActive).toBe(true);
      expect(result.roles).toHaveLength(1);
      expect(result.roles[0]).toBeInstanceOf(UserRoleModel);
      expect(result.roles[0].roleId).toBe('role-id');
      expect(result.roles[0].roleName).toBe('OWNER');
      expect(result.roles[0].gymId).toBe('gym-id');
    });
  });
});
