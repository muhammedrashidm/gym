import { CreateProfileDto } from '../dto/create-profile.dto';
import { UpdateProfileDto } from '../dto/update-profile.dto';
import { StaffCreateProfileDto } from '../dto/staff-create-profile.dto';
import { ProfileModel } from '../models/profile.model';
import { DisableProfileModel } from '../models/disable-profile.model';

export interface IUsersController {
  // --- MEMBER SELF-ONBOARDING ---
  createProfile(req: any, dto: CreateProfileDto): Promise<ProfileModel>;
  updateProfile(req: any, dto: UpdateProfileDto): Promise<ProfileModel>;
  disableProfile(req: any): Promise<DisableProfileModel>;

  // --- STAFF PROFILE MANAGEMENT ---
  staffCreateProfile(req: any, dto: StaffCreateProfileDto): Promise<ProfileModel>;
  staffUpdateProfile(profileId: string, dto: UpdateProfileDto): Promise<ProfileModel>;
  staffDisableProfile(profileId: string): Promise<DisableProfileModel>;
}
