import type { RequestContext } from '../../common/types/request-context.type';
import type {
  ApiResponseDto,
  PaginatedResponseDto,
  PaginationQueryDto,
} from '../../common/dto/api-response.dto';
import type {
  CompleteWorkoutSessionDto,
  SkipWorkoutSessionDto,
  WorkoutSessionResponseDto,
} from '../dto/workout-session.dto';

export interface IWorkoutSessionController {
  complete(
    profileId: string,
    dto: CompleteWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<ApiResponseDto<WorkoutSessionResponseDto>>;

  skip(
    profileId: string,
    dto: SkipWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<ApiResponseDto<WorkoutSessionResponseDto>>;

  findAll(
    profileId: string,
    query: PaginationQueryDto,
    ctx: RequestContext,
  ): Promise<PaginatedResponseDto<WorkoutSessionResponseDto>>;
}
