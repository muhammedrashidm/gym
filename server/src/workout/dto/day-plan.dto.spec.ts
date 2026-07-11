import { validate } from 'class-validator';
import { DayPlanInputDto } from './day-plan.dto';
import { plainToInstance } from 'class-transformer';

describe('DayPlanInputDto Validation', () => {
  it('should fail validation if isRestDay is false and task sets are less than 1', async () => {
    const dayPlan = plainToInstance(DayPlanInputDto, {
      dayIndex: 1,
      isRestDay: false,
      tasks: [
        {
          sequenceIndex: 1,
          name: 'Squat',
          sets: 0, // Invalid
          reps: '10',
        },
      ],
    });

    const errors = await validate(dayPlan);
    expect(errors.length).toBeGreaterThan(0);
  });

  it('should pass validation if isRestDay is true even if task sets are less than 1', async () => {
    const dayPlan = plainToInstance(DayPlanInputDto, {
      dayIndex: 2,
      isRestDay: true,
      tasks: [
        {
          sequenceIndex: 1,
          name: 'Squat',
          sets: 0, // Would be invalid, but should be ignored because isRestDay is true
          reps: '10',
        },
      ],
    });

    const errors = await validate(dayPlan);
    expect(errors.length).toBe(0);
  });
});
