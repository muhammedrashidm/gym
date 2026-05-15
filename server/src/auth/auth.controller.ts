import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { JwtRefreshGuard } from './guards/jwt-refresh.guard';
import { Public } from './decorators/public.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import type { AuthUser } from './interfaces/auth-user.interface';
import type { IAuthController } from './interfaces/auth-controller.interface';
import { OtpRequestedModel } from './models/otp-requested.model';
import { VerifyOtpResponseModel } from './models/verify-otp-response.model';
import { TokenPairModel } from './models/token-pair.model';
import { LogoutModel } from './models/logout.model';
import { AuthUserModel } from './models/auth-user.model';

@ApiTags('auth')
@Controller('auth')
export class AuthController implements IAuthController {
  constructor(private readonly authService: AuthService) {}

  // POST /api/v1/auth/request-otp
  @Public()
  @Post('request-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request an OTP to be sent to the given phone number' })
  @ApiBody({ type: RequestOtpDto })
  @ApiResponse({ status: 200, description: 'OTP sent successfully', type: OtpRequestedModel })
  @ApiResponse({ status: 400, description: 'Invalid phone number format' })
  async requestOtp(@Body() dto: RequestOtpDto): Promise<OtpRequestedModel> {
    return this.authService.requestOtp(dto.phoneNumber);
  }

  // POST /api/v1/auth/verify-otp
  @Public()
  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and receive access + refresh tokens' })
  @ApiBody({ type: VerifyOtpDto })
  @ApiResponse({ status: 200, description: 'Verification successful', type: VerifyOtpResponseModel })
  @ApiResponse({ status: 401, description: 'Invalid or expired OTP' })
  async verifyOtp(@Body() dto: VerifyOtpDto): Promise<VerifyOtpResponseModel> {
    return this.authService.verifyOtp(dto.phoneNumber, dto.code);
  }

  // POST /api/v1/auth/refresh  — expects refresh token as Bearer header
  @Public()
  @UseGuards(JwtRefreshGuard)
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Rotate refresh token and receive a new token pair' })
  @ApiResponse({ status: 200, description: 'New token pair issued', type: TokenPairModel })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refresh(@CurrentUser() user: { refreshToken: string }): Promise<TokenPairModel> {
    return this.authService.refresh(user.refreshToken);
  }

  // POST /api/v1/auth/logout
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Revoke the current refresh token (logout)' })
  @ApiResponse({ status: 200, description: 'Logged out successfully', type: LogoutModel })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async logout(
    @CurrentUser() user: AuthUser,
    @Body('refreshToken') refreshToken: string,
  ): Promise<LogoutModel> {
    return this.authService.logout(user.id, refreshToken);
  }

  // GET /api/v1/auth/me
  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Retrieve the currently authenticated user and their roles' })
  @ApiResponse({ status: 200, description: 'Current user details', type: AuthUserModel })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMe(@CurrentUser() user: AuthUser): Promise<AuthUserModel> {
    return this.authService.getMe(user.id);
  }

  // POST /api/v1/auth/claim-owner
  @Post('claim-owner')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Assign Role ID 3 (Owner) to the authenticated user' })
  @ApiResponse({ status: 200, description: 'Role assigned successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async claimOwner(@CurrentUser() user: AuthUser): Promise<{ success: boolean }> {
    return this.authService.claimOwner(user.id);
  }
}
