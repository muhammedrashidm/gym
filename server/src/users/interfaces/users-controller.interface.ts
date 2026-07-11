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

export interface IUsersController {
  // --- MEMBER SELF-ONBOARDING ---
  createProfile(dto: CreateProfileDto, user: any): Promise<ProfileModel>;
  updateProfile(req: any, dto: UpdateProfileDto): Promise<ProfileModel>;
  disableProfile(req: any): Promise<DisableProfileModel>;
  trainerSignup(
    dto: TrainerSignupDto,
    user: any,
    files: Express.Multer.File[],
  ): Promise<TokenPairModel>;

  // --- STAFF PROFILE MANAGEMENT ---
  staffCreateProfile(
    req: any,
    dto: StaffCreateProfileDto,
  ): Promise<ProfileModel>;
  staffUpdateProfile(
    profileId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileModel>;
  staffDisableProfile(profileId: string): Promise<DisableProfileModel>;

  // --- STAFF-CLIENT CONNECTION ---
  generateStaffQrToken(user: any): Promise<QrTokenModel>;
  connectToTrainer(
    dto: ConnectTrainerDto,
    user: any,
  ): Promise<StaffClientConnectionModel>;
  getStaffClients(user: any): Promise<ProfileModel[]>;
}
