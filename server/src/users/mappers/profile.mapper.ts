import { ProfileModel } from '../models/profile.model';
import { BodyMetricsModel } from '../models/body-metrics.model';
import { DisableProfileModel } from '../models/disable-profile.model';
import { BodyMetrics, Profile } from '@prisma/client';

type ProfileWithMetrics = Profile & { bodyMetrics: BodyMetrics[] };

/**
 * Maps a Prisma Profile (with included bodyMetrics) to a {@link ProfileModel}.
 */
export function mapToProfileModel(profile: ProfileWithMetrics): ProfileModel {
  const model = new ProfileModel();
  model.id = profile.id;
  model.userId = profile.userId ?? null;
  model.phoneNumber = profile.phoneNumber;
  model.fullName = profile.fullName;
  model.age = profile.age ?? null;
  model.sex = profile.sex ?? null;
  model.expLevel = profile.expLevel ?? null;
  model.isKinetic = profile.isKinetic;
  model.isClaimed = profile.isClaimed;
  model.avatarUrl = profile.avatarUrl ?? null;
  model.isActive = profile.isActive;
  model.createdAt = profile.createdAt;
  model.bodyMetrics = profile.bodyMetrics.map((bm) => {
    const metricsModel = new BodyMetricsModel();
    metricsModel.id = bm.id;
    metricsModel.weight = bm.weight;
    metricsModel.height = bm.height;
    metricsModel.muscleMass = bm.muscleMass ?? null;
    metricsModel.bodyFatPct = bm.bodyFatPct ?? null;
    metricsModel.recordedAt = bm.recordedAt;
    return metricsModel;
  });
  return model;
}

/**
 * Creates a {@link DisableProfileModel} success response.
 */
export function mapToDisableProfileModel(): DisableProfileModel {
  const model = new DisableProfileModel();
  model.success = true;
  return model;
}
