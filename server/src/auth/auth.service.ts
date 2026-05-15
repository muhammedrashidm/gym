import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import type { IAuthService } from './interfaces/auth-service.interface';
import { OtpRequestedModel } from './models/otp-requested.model';
import { VerifyOtpResponseModel } from './models/verify-otp-response.model';
import { TokenPairModel } from './models/token-pair.model';
import { LogoutModel } from './models/logout.model';
import { AuthUserModel } from './models/auth-user.model';
import { UserRoleModel } from './models/user-role.model';
import { mapToAuthUserModel } from './mappers/auth.mapper';
import { mapToProfileModel } from '../users/mappers/profile.mapper';

@Injectable()
export class AuthService implements IAuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private config: ConfigService,
  ) { }

  async requestOtp(phoneNumber: string): Promise<OtpRequestedModel> {
    const isDev = this.config.get('NODE_ENV') === 'development';
    const code = isDev
      ? '1234'
      : Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await this.prisma.otpRequest.create({
      data: {
        phoneNumber,
        code,
        expiresAt,
      },
    });

    if (isDev) {
      console.log(`[OTP Stub] Code for ${phoneNumber}: ${code}`);
    } else {
      console.log(`[OTP Stub] Code for ${phoneNumber}: ${code}`); // fallback logging
    }

    const result = new OtpRequestedModel();
    result.success = true;
    return result;
  }

  async verifyOtp(phoneNumber: string, code: string): Promise<VerifyOtpResponseModel> {
    const otpRequest = await this.prisma.otpRequest.findFirst({
      where: {
        phoneNumber,
        verified: false,
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!otpRequest || otpRequest.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    const isDev = this.config.get('NODE_ENV') === 'development';
    if (isDev) {
      if (code !== '1234') throw new UnauthorizedException('Invalid OTP');
    } else {
      if (otpRequest.code !== code)
        throw new UnauthorizedException('Invalid OTP');
    }

    await this.prisma.otpRequest.update({
      where: { id: otpRequest.id },
      data: { verified: true },
    });

    let user = await this.prisma.user.findUnique({
      where: { phoneNumber },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: { phoneNumber },
      });
    }

    const unclaimedProfile = await this.prisma.profile.findFirst({
      where: { phoneNumber, isClaimed: false },
    });

    let claimedPrismaProfile: (typeof unclaimedProfile & { bodyMetrics: any[] }) | null = null;
    if (unclaimedProfile) {
      const updated = await this.prisma.profile.update({
        where: { id: unclaimedProfile.id },
        data: {
          userId: user.id,
          isClaimed: true,
        },
        include: { bodyMetrics: true },
      });
      claimedPrismaProfile = updated;

      const memberRole = await this.prisma.role.findUnique({
        where: { name: 'member' },
      });

      if (memberRole) {
        const existingRole = await this.prisma.userRole.findFirst({
          where: {
            userId: user.id,
            roleId: memberRole.id,
            gymId: updated.createdAtGymId,
          },
        });

        if (!existingRole) {
          await this.prisma.userRole.create({
            data: {
              userId: user.id,
              roleId: memberRole.id,
              gymId: updated.createdAtGymId,
            },
          });
        }
      }
    }

    const userRoles = await this.prisma.userRole.findMany({
      where: { userId: user.id },
      include: { role: true },
    });

    const roles: UserRoleModel[] = userRoles.map((ur) => {
      const r = new UserRoleModel();
      r.roleId = ur.role.id;
      r.roleName = ur.role.name;
      r.gymId = ur.gymId ?? null;
      return r;
    });

    const payload = {
      sub: user.id,
      phone: user.phoneNumber,
      roles,
    };

    const accessToken = this.jwtService.sign(payload);

    const rawRefreshToken = crypto.randomUUID();
    const tokenHash = crypto
      .createHash('sha256')
      .update(rawRefreshToken)
      .digest('hex');

    const refreshExpiresDays =
      this.config.get<number>('REFRESH_TOKEN_EXPIRES_DAYS') || 30;
    const expiresAt = new Date(
      Date.now() + refreshExpiresDays * 24 * 60 * 60 * 1000,
    );

    await this.prisma.refreshToken.create({
      data: {
        token: tokenHash,
        userId: user.id,
        expiresAt,
      },
    });

    const response = new VerifyOtpResponseModel();
    response.accessToken = accessToken;
    response.refreshToken = rawRefreshToken;
    response.user = mapToAuthUserModel(user, userRoles);
    response.claimedProfile = claimedPrismaProfile
      ? mapToProfileModel(claimedPrismaProfile)
      : null;
    return response;
  }

  async refresh(rawRefreshToken: string): Promise<TokenPairModel> {
    const tokenHash = crypto
      .createHash('sha256')
      .update(rawRefreshToken)
      .digest('hex');

    const refreshTokenRecord = await this.prisma.refreshToken.findUnique({
      where: { token: tokenHash },
    });

    if (
      !refreshTokenRecord ||
      refreshTokenRecord.isRevoked ||
      refreshTokenRecord.expiresAt < new Date()
    ) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    await this.prisma.refreshToken.update({
      where: { id: refreshTokenRecord.id },
      data: { isRevoked: true },
    });

    const user = await this.prisma.user.findUnique({
      where: { id: refreshTokenRecord.userId },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }

    const userRoles = await this.prisma.userRole.findMany({
      where: { userId: user.id },
      include: { role: true },
    });

    const roles: UserRoleModel[] = userRoles.map((ur) => {
      const r = new UserRoleModel();
      r.roleId = ur.role.id;
      r.roleName = ur.role.name;
      r.gymId = ur.gymId ?? null;
      return r;
    });

    const payload = {
      sub: user.id,
      phone: user.phoneNumber,
      roles,
    };

    const accessToken = this.jwtService.sign(payload);

    const newRawRefreshToken = crypto.randomUUID();
    const newTokenHash = crypto
      .createHash('sha256')
      .update(newRawRefreshToken)
      .digest('hex');

    const refreshExpiresDays =
      this.config.get<number>('REFRESH_TOKEN_EXPIRES_DAYS') || 30;
    const expiresAt = new Date(
      Date.now() + refreshExpiresDays * 24 * 60 * 60 * 1000,
    );

    await this.prisma.refreshToken.create({
      data: {
        token: newTokenHash,
        userId: user.id,
        expiresAt,
      },
    });

    const result = new TokenPairModel();
    result.accessToken = accessToken;
    result.refreshToken = newRawRefreshToken;
    return result;
  }

  async logout(userId: string, rawRefreshToken: string): Promise<LogoutModel> {
    const tokenHash = crypto
      .createHash('sha256')
      .update(rawRefreshToken)
      .digest('hex');

    await this.prisma.refreshToken.updateMany({
      where: {
        token: tokenHash,
        userId,
      },
      data: { isRevoked: true },
    });

    const result = new LogoutModel();
    result.success = true;
    return result;
  }

  async getMe(userId: string): Promise<AuthUserModel> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, phoneNumber: true, isActive: true },
    });

    const userRoles = await this.prisma.userRole.findMany({
      where: { userId: userId!, role: { isActive: true } },
      include: { role: true },
    });

    return mapToAuthUserModel(user!, userRoles);
  }

  async claimOwner(userId: string): Promise<{ success: boolean }> {
    const ownerRoleId = 3; // Owner

    const existingRole = await this.prisma.userRole.findFirst({
      where: {
        userId,
        roleId: ownerRoleId,
      },
    });

    if (!existingRole) {
      await this.prisma.userRole.create({
        data: {
          userId,
          roleId: ownerRoleId,
        },
      });
    }

    return { success: true };
  }
}
