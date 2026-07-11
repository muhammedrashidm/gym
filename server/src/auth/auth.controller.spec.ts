import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { AuthUser } from './interfaces/auth-user.interface';
import { OtpRequestedModel } from './models/otp-requested.model';
import { VerifyOtpResponseModel } from './models/verify-otp-response.model';
import { TokenPairModel } from './models/token-pair.model';
import { LogoutModel } from './models/logout.model';
import { AuthUserModel } from './models/auth-user.model';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: jest.Mocked<AuthService>;

  beforeEach(async () => {
    // Create a mock of the AuthService
    const mockAuthService = {
      requestOtp: jest.fn(),
      verifyOtp: jest.fn(),
      refresh: jest.fn(),
      logout: jest.fn(),
      getMe: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get(AuthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('requestOtp', () => {
    it('should call authService.requestOtp and return OtpRequestedModel', async () => {
      const dto: RequestOtpDto = { phoneNumber: '+1234567890' };
      const expectedResult = new OtpRequestedModel();
      expectedResult.success = true;

      authService.requestOtp.mockResolvedValue(expectedResult);

      const result = await controller.requestOtp(dto);

      expect(authService.requestOtp).toHaveBeenCalledWith(dto.phoneNumber);
      expect(result).toBeInstanceOf(OtpRequestedModel);
      expect(result.success).toBe(true);
    });
  });

  describe('verifyOtp', () => {
    it('should call authService.verifyOtp and return VerifyOtpResponseModel', async () => {
      const dto: VerifyOtpDto = { phoneNumber: '+1234567890', code: '1234' };
      const expectedResult = new VerifyOtpResponseModel();
      expectedResult.accessToken = 'access-token';
      expectedResult.refreshToken = 'refresh-token';
      expectedResult.user = new AuthUserModel();
      expectedResult.user.id = 'uuid';
      expectedResult.user.phoneNumber = dto.phoneNumber;
      expectedResult.user.isActive = true;
      expectedResult.user.roles = [];
      expectedResult.claimedProfile = null;

      authService.verifyOtp.mockResolvedValue(expectedResult);

      const result = await controller.verifyOtp(dto);

      expect(authService.verifyOtp).toHaveBeenCalledWith(
        dto.phoneNumber,
        dto.code,
        false,
      );
      expect(result).toBeInstanceOf(VerifyOtpResponseModel);
      expect(result.accessToken).toBe('access-token');
      expect(result.user).toBeInstanceOf(AuthUserModel);
    });

    it('should call authService.verifyOtp with isMobile=true when x-client-platform is mobile', async () => {
      const dto: VerifyOtpDto = { phoneNumber: '+1234567890', code: '1234' };
      const expectedResult = new VerifyOtpResponseModel();
      expectedResult.accessToken = 'access-token';
      expectedResult.refreshToken = 'refresh-token';
      expectedResult.user = new AuthUserModel();
      expectedResult.user.id = 'uuid';
      expectedResult.user.phoneNumber = dto.phoneNumber;
      expectedResult.user.isActive = true;
      expectedResult.user.roles = [];
      expectedResult.claimedProfile = null;

      authService.verifyOtp.mockResolvedValue(expectedResult);

      const result = await controller.verifyOtp(dto, 'mobile');

      expect(authService.verifyOtp).toHaveBeenCalledWith(
        dto.phoneNumber,
        dto.code,
        true,
      );
      expect(result).toBeInstanceOf(VerifyOtpResponseModel);
    });
  });

  describe('refresh', () => {
    it('should call authService.refresh and return TokenPairModel', async () => {
      const user = { refreshToken: 'old-refresh-token' };
      const expectedResult = new TokenPairModel();
      expectedResult.accessToken = 'new-access-token';
      expectedResult.refreshToken = 'new-refresh-token';

      authService.refresh.mockResolvedValue(expectedResult);

      const result = await controller.refresh(user);

      expect(authService.refresh).toHaveBeenCalledWith(user.refreshToken);
      expect(result).toBeInstanceOf(TokenPairModel);
      expect(result.accessToken).toBe('new-access-token');
    });
  });

  describe('logout', () => {
    it('should call authService.logout with user.id and refreshToken', async () => {
      const user: AuthUser = {
        id: 'user-uuid',
        phoneNumber: '+1234567890',
        isActive: true,
        roles: [],
      };
      const refreshToken = 'refresh-token-to-revoke';
      const expectedResult = new LogoutModel();
      expectedResult.success = true;

      authService.logout.mockResolvedValue(expectedResult);

      const result = await controller.logout(user, refreshToken);

      expect(authService.logout).toHaveBeenCalledWith(user.id, refreshToken);
      expect(result).toBeInstanceOf(LogoutModel);
      expect(result.success).toBe(true);
    });
  });

  describe('getMe', () => {
    it('should call authService.getMe with user.id and return AuthUserModel', async () => {
      const user: AuthUser = {
        id: 'user-uuid',
        phoneNumber: '+1234567890',
        isActive: true,
        roles: [],
      };
      const expectedResult = new AuthUserModel();
      expectedResult.id = 'user-uuid';
      expectedResult.phoneNumber = '+1234567890';
      expectedResult.isActive = true;
      expectedResult.roles = [];

      authService.getMe.mockResolvedValue(expectedResult);

      const result = await controller.getMe(user);

      expect(authService.getMe).toHaveBeenCalledWith(user.id);
      expect(result).toBeInstanceOf(AuthUserModel);
      expect(result.id).toBe('user-uuid');
    });
  });
});
