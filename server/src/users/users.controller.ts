import {
  Controller,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
  ApiParam,
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { StaffCreateProfileDto } from './dto/staff-create-profile.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import type { IUsersController } from './interfaces/users-controller.interface';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController implements IUsersController {
  constructor(private readonly usersService: UsersService) { }


  // ── MEMBER SELF-ONBOARDING ─────────────────────────────────────────────────

  @Post('profile')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create the authenticated member\'s profile' })
  @ApiBody({ type: CreateProfileDto })
  @ApiResponse({ status: 201, description: 'Profile created', type: ProfileModel })
  @ApiResponse({ status: 400, description: 'Profile already exists' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createProfile(@Body() dto: CreateProfileDto, @CurrentUser() user: any): Promise<ProfileModel> {
    const userId = user.id;
    const phoneNumber = user.phoneNumber;
    return this.usersService.createProfile(userId, phoneNumber, dto);
  }

  @Put('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update the authenticated member\'s profile' })
  @ApiBody({ type: UpdateProfileDto })
  @ApiResponse({ status: 200, description: 'Profile updated', type: ProfileModel })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProfile(@Req() req: any, @Body() dto: UpdateProfileDto): Promise<ProfileModel> {
    const userId = req.user.id ?? req.user.sub;
    return this.usersService.updateProfile(userId, dto);
  }

  @Delete('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate (soft-delete) the authenticated member\'s profile' })
  @ApiResponse({ status: 200, description: 'Profile deactivated', type: DisableProfileModel })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async disableProfile(@Req() req: any): Promise<DisableProfileModel> {
    const userId = req.user.id ?? req.user.sub;
    return this.usersService.disableProfile(userId);
  }


  // ── STAFF PROFILE MANAGEMENT ───────────────────────────────────────────────

  @Post('manage/members')
  @HttpCode(HttpStatus.CREATED)
  @Roles('staff', 'owner', 'admin')
  @ApiOperation({ summary: 'Staff: create a member profile (with optional auto-link)' })
  @ApiBody({ type: StaffCreateProfileDto })
  @ApiResponse({ status: 201, description: 'Member profile created', type: ProfileModel })
  @ApiResponse({ status: 400, description: 'Profile with this phone number already exists' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – staff, owner, or admin role required' })
  async staffCreateProfile(@Req() req: any, @Body() dto: StaffCreateProfileDto): Promise<ProfileModel> {
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
  @ApiResponse({ status: 200, description: 'Member profile updated', type: ProfileModel })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – staff, owner, or admin role required' })
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
  @ApiParam({ name: 'profileId', description: 'UUID of the profile to deactivate' })
  @ApiResponse({ status: 200, description: 'Member profile deactivated', type: DisableProfileModel })
  @ApiResponse({ status: 404, description: 'Profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – staff, owner, or admin role required' })
  async staffDisableProfile(@Param('profileId') profileId: string): Promise<DisableProfileModel> {
    return this.usersService.staffDisableProfile(profileId);
  }
}
