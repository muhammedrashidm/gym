import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { StaffCreateProfileDto } from './dto/staff-create-profile.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { ProfileModel } from './models/profile.model';
import { DisableProfileModel } from './models/disable-profile.model';
import { BodyMetricsModel } from './models/body-metrics.model';

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  const mockUsersService = {
    createProfile: jest.fn(),
    updateProfile: jest.fn(),
    disableProfile: jest.fn(),
    staffCreateProfile: jest.fn(),
    staffUpdateProfile: jest.fn(),
    staffDisableProfile: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('createProfile', () => {
    it('should call usersService.createProfile with correct parameters', async () => {
      const dto: CreateProfileDto = { fullName: 'Test User' };
      const user = { id: 'user-123', phoneNumber: '+1234567890' };
      const expectedProfile = new ProfileModel();
      expectedProfile.id = 'prof-1';
      expectedProfile.userId = 'user-123';
      expectedProfile.phoneNumber = '+1234567890';
      expectedProfile.fullName = 'Test User';
      expectedProfile.isActive = true;
      expectedProfile.isClaimed = true;
      expectedProfile.bodyMetrics = [];
      mockUsersService.createProfile.mockResolvedValueOnce(expectedProfile);

      const result = await controller.createProfile(dto, user);

      expect(service.createProfile).toHaveBeenCalledWith('user-123', '+1234567890', dto);
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.id).toBe('prof-1');
    });
  });

  describe('updateProfile', () => {
    it('should call usersService.updateProfile with correct parameters', async () => {
      const dto: UpdateProfileDto = { fullName: 'Updated Name' };
      const req = { user: { sub: 'user-123' } };
      const expectedProfile = new ProfileModel();
      expectedProfile.id = 'prof-1';
      expectedProfile.fullName = 'Updated Name';
      expectedProfile.isActive = true;
      expectedProfile.bodyMetrics = [];
      mockUsersService.updateProfile.mockResolvedValueOnce(expectedProfile);

      const result = await controller.updateProfile(req, dto);

      expect(service.updateProfile).toHaveBeenCalledWith('user-123', dto);
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.fullName).toBe('Updated Name');
    });
  });

  describe('disableProfile', () => {
    it('should call usersService.disableProfile with correct parameters', async () => {
      const req = { user: { sub: 'user-123' } };
      const expectedResult = new DisableProfileModel();
      expectedResult.success = true;
      mockUsersService.disableProfile.mockResolvedValueOnce(expectedResult);

      const result = await controller.disableProfile(req);

      expect(service.disableProfile).toHaveBeenCalledWith('user-123');
      expect(result).toBeInstanceOf(DisableProfileModel);
      expect(result.success).toBe(true);
    });
  });

  describe('staffCreateProfile', () => {
    it('should call usersService.staffCreateProfile with correct parameters', async () => {
      const dto: StaffCreateProfileDto = { fullName: 'Walk In', phoneNumber: '+1999999999' };
      const req = { user: { sub: 'staff-123', activeGymId: 'gym-456' } };
      const expectedProfile = new ProfileModel();
      expectedProfile.id = 'prof-1';
      expectedProfile.phoneNumber = '+1999999999';
      expectedProfile.fullName = 'Walk In';
      expectedProfile.isActive = true;
      expectedProfile.bodyMetrics = [];
      mockUsersService.staffCreateProfile.mockResolvedValueOnce(expectedProfile);

      const result = await controller.staffCreateProfile(req, dto);

      expect(service.staffCreateProfile).toHaveBeenCalledWith('gym-456', 'staff-123', dto);
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.id).toBe('prof-1');
    });

    it('should handle missing activeGymId gracefully', async () => {
      const dto: StaffCreateProfileDto = { fullName: 'Walk In', phoneNumber: '+1999999999' };
      const req = { user: { sub: 'staff-123' } }; // no activeGymId
      const expectedProfile = new ProfileModel();
      expectedProfile.id = 'prof-1';
      mockUsersService.staffCreateProfile.mockResolvedValueOnce(expectedProfile);

      const result = await controller.staffCreateProfile(req, dto);

      expect(service.staffCreateProfile).toHaveBeenCalledWith(null, 'staff-123', dto);
      expect(result).toBeInstanceOf(ProfileModel);
    });
  });

  describe('staffUpdateProfile', () => {
    it('should call usersService.staffUpdateProfile with correct parameters', async () => {
      const dto: UpdateProfileDto = { fullName: 'Updated Walk In' };
      const profileId = 'prof-456';
      const expectedProfile = new ProfileModel();
      expectedProfile.id = profileId;
      expectedProfile.fullName = 'Updated Walk In';
      expectedProfile.isActive = true;
      expectedProfile.bodyMetrics = [];
      mockUsersService.staffUpdateProfile.mockResolvedValueOnce(expectedProfile);

      const result = await controller.staffUpdateProfile(profileId, dto);

      expect(service.staffUpdateProfile).toHaveBeenCalledWith(profileId, dto);
      expect(result).toBeInstanceOf(ProfileModel);
      expect(result.id).toBe(profileId);
    });
  });

  describe('staffDisableProfile', () => {
    it('should call usersService.staffDisableProfile with correct parameters', async () => {
      const profileId = 'prof-456';
      const expectedResult = new DisableProfileModel();
      expectedResult.success = true;
      mockUsersService.staffDisableProfile.mockResolvedValueOnce(expectedResult);

      const result = await controller.staffDisableProfile(profileId);

      expect(service.staffDisableProfile).toHaveBeenCalledWith(profileId);
      expect(result).toBeInstanceOf(DisableProfileModel);
      expect(result.success).toBe(true);
    });
  });
});
