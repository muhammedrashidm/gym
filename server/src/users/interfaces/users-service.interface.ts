import { CreateProfileDto } from '../dto/create-profile.dto';
import { UpdateProfileDto } from '../dto/update-profile.dto';
import { StaffCreateProfileDto } from '../dto/staff-create-profile.dto';
import { ProfileModel } from '../models/profile.model';
import { DisableProfileModel } from '../models/disable-profile.model';

export interface IUsersService {
  // --- MEMBER SELF-ONBOARDING ---
  createProfile(userId: string, phoneNumber: string, dto: CreateProfileDto): Promise<ProfileModel>;
  updateProfile(userId: string, dto: UpdateProfileDto): Promise<ProfileModel>;
  disableProfile(userId: string): Promise<DisableProfileModel>;

  // --- STAFF PROFILE MANAGEMENT ---
  staffCreateProfile(gymId: string | null, staffUserId: string, dto: StaffCreateProfileDto): Promise<ProfileModel>;
  staffUpdateProfile(profileId: string, dto: UpdateProfileDto): Promise<ProfileModel>;
  staffDisableProfile(profileId: string): Promise<DisableProfileModel>;
}
