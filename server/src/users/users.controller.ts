import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Req,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFiles,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
  ApiParam,
} from '@nestjs/swagger';
import { FilesInterceptor } from '@nestjs/platform-express';
import { UsersService } from './users.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { StaffCreateProfileDto } from './dto/staff-create-profile.dto';
import { TrainerSignupDto } from './dto/trainer-signup.dto';
import { ConnectTrainerDto } from './dto/connect-trainer.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import type { IUsersController } from './interfaces/users-controller.interface';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { QrTokenModel } from './models/qr-token.model';
import { StaffClientConnectionModel } from './models/staff-client-connection.model';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { TokenPairModel } from '../auth/models/token-pair.model';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController implements IUsersController {
  constructor(private readonly usersService: UsersService) {}

  // ── MEMBER SELF-ONBOARDING ─────────────────────────────────────────────────

  @Post('profile')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Create the authenticated member's profile" })
  @ApiBody({ type: CreateProfileDto })
  @ApiResponse({
    status: 201,
    description: 'Profile created',
    type: ProfileModel,
  })
  @ApiResponse({ status: 400, description: 'Profile already exists' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createProfile(
    @Body() dto: CreateProfileDto,
    @CurrentUser() user: any,
  ): Promise<ProfileModel> {
    const userId = user.id;
    const phoneNumber = user.phoneNumber;
    return this.usersService.createProfile(userId, phoneNumber, dto);
  }

  @Put('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Update the authenticated member's profile" })
  @ApiBody({ type: UpdateProfileDto })
  @ApiResponse({
    status: 200,
    description: 'Profile updated',
    type: ProfileModel,
  })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProfile(
    @Req() req: any,
    @Body() dto: UpdateProfileDto,
  ): Promise<ProfileModel> {
    const userId = req.user.id ?? req.user.sub;
    return this.usersService.updateProfile(userId, dto);
  }

  @Delete('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: "Deactivate (soft-delete) the authenticated member's profile",
  })
  @ApiResponse({
    status: 200,
    description: 'Profile deactivated',
    type: DisableProfileModel,
  })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async disableProfile(@Req() req: any): Promise<DisableProfileModel> {
    const userId = req.user.id ?? req.user.sub;
    return this.usersService.disableProfile(userId);
  }

  @Post('trainer-signup')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FilesInterceptor('certificates'))
  @ApiOperation({ summary: 'Register the authenticated member as a trainer' })
  @ApiBody({ type: TrainerSignupDto })
  @ApiResponse({
    status: 200,
    description: 'Trainer onboarding successful, role switch completed.',
    type: TokenPairModel,
  })
  @ApiResponse({ status: 400, description: 'Invalid input or request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async trainerSignup(
    @Body() dto: TrainerSignupDto,
    @CurrentUser() user: any,
    @UploadedFiles() files: Express.Multer.File[],
  ): Promise<TokenPairModel> {
    const userId = user.id;
    return this.usersService.trainerSignup(userId, dto, files || []);
  }

  // ── STAFF PROFILE MANAGEMENT ───────────────────────────────────────────────

  @Post('manage/members')
  @HttpCode(HttpStatus.CREATED)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({
    summary: 'Staff: create a member profile (with optional auto-link)',
  })
  @ApiBody({ type: StaffCreateProfileDto })
  @ApiResponse({
    status: 201,
    description: 'Member profile created',
    type: ProfileModel,
  })
  @ApiResponse({
    status: 400,
    description: 'Profile with this phone number already exists',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden – staff, owner, or admin role required',
  })
  async staffCreateProfile(
    @Req() req: any,
    @Body() dto: StaffCreateProfileDto,
  ): Promise<ProfileModel> {
    const staffUserId = req.user.id ?? req.user.sub;
    const gymId =
      req.context?.gymContext?.gymId ??
      req.user.activeGymId ??
      req.headers?.['x-gym-id'] ??
      req.headers?.['x-gym-context'] ??
      null;
    return this.usersService.staffCreateProfile(gymId, staffUserId, dto);
  }

  @Put('manage/members/:profileId')
  @HttpCode(HttpStatus.OK)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({ summary: 'Staff: update an existing member profile' })
  @ApiParam({ name: 'profileId', description: 'UUID of the profile to update' })
  @ApiBody({ type: UpdateProfileDto })
  @ApiResponse({
    status: 200,
    description: 'Member profile updated',
    type: ProfileModel,
  })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden – staff, owner, or admin role required',
  })
  async staffUpdateProfile(
    @Param('profileId') profileId: string,
    @Body() dto: UpdateProfileDto,
  ): Promise<ProfileModel> {
    return this.usersService.staffUpdateProfile(profileId, dto);
  }

  @Delete('manage/members/:profileId')
  @HttpCode(HttpStatus.OK)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({ summary: 'Staff: deactivate (soft-delete) a member profile' })
  @ApiParam({
    name: 'profileId',
    description: 'UUID of the profile to deactivate',
  })
  @ApiResponse({
    status: 200,
    description: 'Member profile deactivated',
    type: DisableProfileModel,
  })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden – staff, owner, or admin role required',
  })
  async staffDisableProfile(
    @Param('profileId') profileId: string,
  ): Promise<DisableProfileModel> {
    return this.usersService.staffDisableProfile(profileId);
  }

  // ── STAFF-CLIENT CONNECTION ──────────────────────────────────────────────────

  @Post('staff/qr-token')
  @HttpCode(HttpStatus.OK)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({
    summary: 'Staff: generate a unique QR token to show to clients',
  })
  @ApiResponse({
    status: 200,
    description: 'QR token successfully generated',
    type: QrTokenModel,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden – staff, owner, or admin role required',
  })
  async generateStaffQrToken(@CurrentUser() user: any): Promise<QrTokenModel> {
    const staffUserId = user.id ?? user.sub;
    return this.usersService.generateStaffQrToken(staffUserId);
  }

  @Post('connect-trainer')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Client: connect to a trainer via their QR token' })
  @ApiBody({ type: ConnectTrainerDto })
  @ApiResponse({
    status: 200,
    description: 'Successfully connected to trainer',
    type: StaffClientConnectionModel,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid QR token or connection error',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async connectToTrainer(
    @Body() dto: ConnectTrainerDto,
    @CurrentUser() user: any,
  ): Promise<StaffClientConnectionModel> {
    const clientUserId = user.id ?? user.sub;
    return this.usersService.connectToTrainer(clientUserId, dto);
  }

  @Get('staff/clients')
  @HttpCode(HttpStatus.OK)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({
    summary:
      'Staff: list all connected clients (athletes) for the authenticated trainer',
  })
  @ApiResponse({
    status: 200,
    description: 'List of connected client profiles',
    type: [ProfileModel],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden – staff, owner, or admin role required',
  })
  async getStaffClients(@CurrentUser() user: any): Promise<ProfileModel[]> {
    const staffUserId = user.id ?? user.sub;
    return this.usersService.listStaffClients(staffUserId);
  }
}
