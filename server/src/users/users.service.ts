import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { StaffCreateProfileDto } from './dto/staff-create-profile.dto';
import { TrainerSignupDto } from './dto/trainer-signup.dto';
import { ConnectTrainerDto } from './dto/connect-trainer.dto';
import type { IUsersService } from './interfaces/users-service.interface';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { QrTokenModel } from './models/qr-token.model';
import { StaffClientConnectionModel } from './models/staff-client-connection.model';
import {
  mapToProfileModel,
  mapToDisableProfileModel,
} from './mappers/profile.mapper';
import type { User } from 'generated/prisma/client';
import { AuthService } from '../auth/auth.service';
import { TokenPairModel } from '../auth/models/token-pair.model';
import { randomUUID } from 'crypto';

@Injectable()
export class UsersService implements IUsersService {
  constructor(
    private prisma: PrismaService,
    private authService: AuthService,
  ) {}

  // ── Internal helpers (not part of IUsersService) ───────────────────────────

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async findByPhone(phoneNumber: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { phoneNumber } });
  }

  // ── MEMBER SELF-ONBOARDING ─────────────────────────────────────────────────

  async createProfile(
    userId: string,
    phoneNumber: string,
    dto: CreateProfileDto,
  ): Promise<ProfileModel> {
    const existing = await this.prisma.profile.findUnique({
      where: { userId },
    });
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
        bodyMetrics:
          weight && height
            ? {
                create: { weight, height, muscleMass, bodyFatPct },
              }
            : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(profile);
  }

  async updateProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileModel> {
    const profile = await this.prisma.profile.findUnique({ where: { userId } });
    if (!profile) {
      throw new NotFoundException('Profile not found');
    }

    const { weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const updated = await this.prisma.profile.update({
      where: { userId },
      data: {
        ...profileData,
        bodyMetrics:
          weight && height
            ? {
                create: { weight, height, muscleMass, bodyFatPct },
              }
            : undefined,
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

  async staffCreateProfile(
    gymId: string | null,
    staffUserId: string,
    dto: StaffCreateProfileDto,
  ): Promise<ProfileModel> {
    const {
      phoneNumber,
      weight,
      height,
      muscleMass,
      bodyFatPct,
      ...profileData
    } = dto;

    const existing = await this.prisma.profile.findUnique({
      where: { phoneNumber },
    });
    if (existing) {
      throw new BadRequestException(
        'Profile with this phone number already exists. Please ask the client to present their QR code to connect.',
      );
    }

    const user = await this.findByPhone(phoneNumber);

    const profile = await this.prisma.profile.create({
      data: {
        ...profileData,
        phoneNumber,
        userId: user ? user.id : null,
        isClaimed: false,
        createdById: staffUserId,
        createdAtGymId: gymId,
        bodyMetrics:
          weight && height
            ? {
                create: { weight, height, muscleMass, bodyFatPct },
              }
            : undefined,
      },
      include: { bodyMetrics: true },
    });

    const staffProfile = await this.prisma.staffProfile.findUnique({
      where: { userId: staffUserId },
    });
    if (staffProfile) {
      await this.prisma.staffClientConnection.create({
        data: {
          staffProfileId: staffProfile.id,
          clientProfileId: profile.id,
          isActive: true,
        },
      });
    }

    return mapToProfileModel(profile);
  }

  async staffUpdateProfile(
    profileId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileModel> {
    const profile = await this.prisma.profile.findUnique({
      where: { id: profileId },
    });
    if (!profile) throw new NotFoundException('Profile not found');

    const { weight, height, muscleMass, bodyFatPct, ...profileData } = dto;

    const updated = await this.prisma.profile.update({
      where: { id: profileId },
      data: {
        ...profileData,
        bodyMetrics:
          weight && height
            ? {
                create: { weight, height, muscleMass, bodyFatPct },
              }
            : undefined,
      },
      include: { bodyMetrics: true },
    });

    return mapToProfileModel(updated);
  }

  async staffDisableProfile(profileId: string): Promise<DisableProfileModel> {
    const profile = await this.prisma.profile.findUnique({
      where: { id: profileId },
    });
    if (!profile) throw new NotFoundException('Profile not found');

    await this.prisma.profile.update({
      where: { id: profileId },
      data: { isActive: false },
    });

    return mapToDisableProfileModel();
  }

  async trainerSignup(
    userId: string,
    dto: TrainerSignupDto,
    files: Express.Multer.File[],
  ): Promise<TokenPairModel> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new BadRequestException('User not found');
    }

    let staffRole = await this.prisma.role.findUnique({
      where: { name: 'staff' },
    });
    if (!staffRole) {
      staffRole = await this.prisma.role.create({
        data: {
          id: 2,
          name: 'staff',
          description: 'Gym staff / trainer',
        },
      });
    }

    const existingUserRole = await this.prisma.userRole.findFirst({
      where: {
        userId,
        roleId: staffRole.id,
      },
    });
    if (!existingUserRole) {
      await this.prisma.userRole.create({
        data: {
          userId,
          roleId: staffRole.id,
          gymId: null,
        },
      });
    }

    let profile = await this.prisma.profile.findUnique({
      where: { userId },
    });
    if (!profile) {
      profile = await this.prisma.profile.create({
        data: {
          userId,
          fullName: dto.name,
          phoneNumber: user.phoneNumber,
          isClaimed: true,
        },
      });
    } else {
      profile = await this.prisma.profile.update({
        where: { userId },
        data: {
          fullName: dto.name,
        },
      });
    }

    // Process certificates files
    const certificateUrls = (files || []).map(
      (f) => f.path || f.filename || `/uploads/${f.originalname}`,
    );

    // Process specializations
    let specializationsList: string[] = [];
    if (dto.specializations) {
      if (typeof dto.specializations === 'string') {
        specializationsList = dto.specializations
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean);
      } else if (Array.isArray(dto.specializations)) {
        specializationsList = dto.specializations
          .map((s) => String(s).trim())
          .filter(Boolean);
      }
    }

    const expYears = parseInt(dto.experience, 10) || 0;
    const existingStaffProfile = await this.prisma.staffProfile.findUnique({
      where: { userId },
    });

    if (existingStaffProfile) {
      await this.prisma.staffProfile.update({
        where: { userId },
        data: {
          bio: dto.bio,
          experience: expYears,
          specializations: specializationsList,
          certificates:
            certificateUrls.length > 0 ? certificateUrls : undefined,
        },
      });
    } else {
      await this.prisma.staffProfile.create({
        data: {
          profileId: profile.id,
          userId,
          bio: dto.bio,
          experience: expYears,
          specializations: specializationsList,
          certificates: certificateUrls,
        },
      });
    }

    console.log(`[Trainer Signup] Persisted staff profile for ${dto.name}`);

    return this.authService.generateTokenPairForUser(userId);
  }

  async generateStaffQrToken(staffUserId: string): Promise<QrTokenModel> {
    const profile = await this.prisma.profile.findUnique({
      where: { userId: staffUserId },
    });
    if (!profile) {
      throw new NotFoundException('Staff profile not found');
    }

    const qrToken = randomUUID();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    await this.prisma.profile.update({
      where: { id: profile.id },
      data: {
        qrToken,
        qrTokenExpiry: expiresAt,
      },
    });

    return { qrToken, expiresAt };
  }

  async connectToTrainer(
    clientUserId: string,
    dto: ConnectTrainerDto,
  ): Promise<StaffClientConnectionModel> {
    const clientProfile = await this.prisma.profile.findUnique({
      where: { userId: clientUserId },
    });
    if (!clientProfile) {
      throw new NotFoundException('Client profile not found');
    }

    const staffProfileCore = await this.prisma.profile.findUnique({
      where: { qrToken: dto.qrToken },
      include: { staffProfile: true },
    });

    if (!staffProfileCore) {
      throw new BadRequestException('Invalid or expired QR token');
    }

    if (
      !staffProfileCore.qrTokenExpiry ||
      staffProfileCore.qrTokenExpiry < new Date()
    ) {
      throw new BadRequestException('QR token has expired');
    }

    const staffProfile = staffProfileCore.staffProfile;
    if (!staffProfile) {
      throw new BadRequestException('Trainer profile is not fully initialized');
    }

    if (staffProfileCore.userId === clientUserId) {
      throw new BadRequestException(
        'Cannot connect to your own trainer profile',
      );
    }

    const existingConnection =
      await this.prisma.staffClientConnection.findUnique({
        where: {
          staffProfileId_clientProfileId: {
            staffProfileId: staffProfile.id,
            clientProfileId: clientProfile.id,
          },
        },
      });

    if (existingConnection) {
      if (existingConnection.isActive) {
        return existingConnection;
      }
      return this.prisma.staffClientConnection.update({
        where: { id: existingConnection.id },
        data: { isActive: true },
      });
    }

    return this.prisma.staffClientConnection.create({
      data: {
        staffProfileId: staffProfile.id,
        clientProfileId: clientProfile.id,
      },
    });
  }

  async listStaffClients(staffUserId: string): Promise<ProfileModel[]> {
    const staffProfile = await this.prisma.staffProfile.findUnique({
      where: { userId: staffUserId },
    });
    if (!staffProfile) {
      throw new NotFoundException('Staff profile not found');
    }

    const connections = await this.prisma.staffClientConnection.findMany({
      where: {
        staffProfileId: staffProfile.id,
        isActive: true,
      },
      include: {
        clientProfile: {
          include: {
            bodyMetrics: true,
          },
        },
      },
    });

    return connections.map((conn) => mapToProfileModel(conn.clientProfile));
  }
}
