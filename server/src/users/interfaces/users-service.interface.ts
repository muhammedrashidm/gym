import { CreateProfileDto } from '../dto/create-profile.dto';
import { UpdateProfileDto } from '../dto/update-profile.dto';
import { StaffCreateProfileDto } from '../dto/staff-create-profile.dto';
import { TrainerSignupDto } from '../dto/trainer-signup.dto';
import { ConnectTrainerDto } from '../dto/connect-trainer.dto';
import { ProfileModel } from '../models/profile.model';
import { DisableProfileModel } from '../models/disable-profile.model';
import { QrTokenModel } from '../models/qr-token.model';
import { StaffClientConnectionModel } from '../models/staff-client-connection.model';
import { TokenPairModel } from '../../auth/models/token-pair.model';

export interface IUsersService {
  // --- MEMBER SELF-ONBOARDING ---
  createProfile(
    userId: string,
    phoneNumber: string,
    dto: CreateProfileDto,
  ): Promise<ProfileModel>;
  updateProfile(userId: string, dto: UpdateProfileDto): Promise<ProfileModel>;
  disableProfile(userId: string): Promise<DisableProfileModel>;

  // --- STAFF PROFILE MANAGEMENT ---
  staffCreateProfile(
    gymId: string | null,
    staffUserId: string,
    dto: StaffCreateProfileDto,
  ): Promise<ProfileModel>;
  staffUpdateProfile(
    profileId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileModel>;
  staffDisableProfile(profileId: string): Promise<DisableProfileModel>;

  trainerSignup(
    userId: string,
    dto: TrainerSignupDto,
    files: Express.Multer.File[],
  ): Promise<TokenPairModel>;

  // --- STAFF-CLIENT CONNECTION ---
  generateStaffQrToken(staffUserId: string): Promise<QrTokenModel>;
  connectToTrainer(
    clientUserId: string,
    dto: ConnectTrainerDto,
  ): Promise<StaffClientConnectionModel>;
  listStaffClients(staffUserId: string): Promise<ProfileModel[]>;
}
