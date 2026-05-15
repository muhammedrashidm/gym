import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { StaffCreateProfileDto } from './dto/staff-create-profile.dto';
import type { IUsersService } from './interfaces/users-service.interface';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { mapToProfileModel, mapToDisableProfileModel } from './mappers/profile.mapper';
import type { User } from 'generated/prisma/client';

@Injectable()
export class UsersService implements IUsersService {

  constructor(private prisma: PrismaService) { }

  // ── Internal helpers (not part of IUsersService) ───────────────────────────

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async findByPhone(phoneNumber: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { phoneNumber } });
  }

  // ── MEMBER SELF-ONBOARDING ─────────────────────────────────────────────────

  async createProfile(userId: string, phoneNumber: string, dto: CreateProfileDto): Promise<ProfileModel> {
    const existing = await this.prisma.profile.findUnique({ where: { userId } });
    if (existing) {
      throw new BadRequestException('Profile already exists');
    }

    const { weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const profile = await this.prisma.profile.create({
      data: {
        ...profileData,
        userId,
        phoneNumber,
        isClaimed: true,
        bodyMetrics: weight && height ? {
          create: { weight, height, muscleMass, bodyFatPct },
        } : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(profile);
  }

  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<ProfileModel> {
    const profile = await this.prisma.profile.findUnique({ where: { userId } });
    if (!profile) {
      throw new NotFoundException('Profile not found');
    }

    const { weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const updated = await this.prisma.profile.update({
      where: { userId },
      data: {
        ...profileData,
        bodyMetrics: weight && height ? {
          create: { weight, height, muscleMass, bodyFatPct },
        } : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(updated);
  }

  async disableProfile(userId: string): Promise<DisableProfileModel> {
    const profile = await this.prisma.profile.findUnique({ where: { userId } });
    if (!profile) throw new NotFoundException('Profile not found');

    await this.prisma.profile.update({
      where: { userId },
      data: { isActive: false },
    });

    return mapToDisableProfileModel();
  }

  // ── STAFF PROFILE MANAGEMENT ───────────────────────────────────────────────

  async staffCreateProfile(gymId: string | null, staffUserId: string, dto: StaffCreateProfileDto): Promise<ProfileModel> {
    const { phoneNumber, weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const existing = await this.prisma.profile.findUnique({ where: { phoneNumber } });
    if (existing) {
      throw new BadRequestException('Profile with this phone number already exists');
    }

    const user = await this.findByPhone(phoneNumber);

    const profile = await this.prisma.profile.create({
      data: {
        ...profileData,
        phoneNumber,
        userId: user ? user.id : null,
        isClaimed: user ? true : false,
        createdById: staffUserId,
        createdAtGymId: gymId,
        bodyMetrics: weight && height ? {
          create: { weight, height, muscleMass, bodyFatPct },
        } : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(profile);
  }

  async staffUpdateProfile(profileId: string, dto: UpdateProfileDto): Promise<ProfileModel> {
    const profile = await this.prisma.profile.findUnique({ where: { id: profileId } });
    if (!profile) throw new NotFoundException('Profile not found');

    const { weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const updated = await this.prisma.profile.update({
      where: { id: profileId },
      data: {
        ...profileData,
        bodyMetrics: weight && height ? {
          create: { weight, height, muscleMass, bodyFatPct },
        } : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(updated);
  }

  async staffDisableProfile(profileId: string): Promise<DisableProfileModel> {
    const profile = await this.prisma.profile.findUnique({ where: { id: profileId } });
    if (!profile) throw new NotFoundException('Profile not found');

    await this.prisma.profile.update({
      where: { id: profileId },
      data: { isActive: false },
    });

    return mapToDisableProfileModel();
  }
}
