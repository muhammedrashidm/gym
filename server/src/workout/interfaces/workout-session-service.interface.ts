import type { RequestContext } from '../../common/types/request-context.type';
import type { PaginationMeta } from '../../common/dto/api-response.dto';
import type {
  CompleteWorkoutSessionDto,
  SkipWorkoutSessionDto,
  WorkoutSessionResponseDto,
} from '../dto/workout-session.dto';

export interface IWorkoutSessionService {
  complete(
    profileId: string,
    dto: CompleteWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto>;

  skip(
    profileId: string,
    dto: SkipWorkoutSessionDto,
    ctx: RequestContext,
  ): Promise<WorkoutSessionResponseDto>;

  findAll(
    profileId: string,
    page: number,
    pageSize: number,
    ctx: RequestContext,
  ): Promise<{ data: WorkoutSessionResponseDto[]; meta: PaginationMeta }>;
}
