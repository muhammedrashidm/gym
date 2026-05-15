import "reflect-metadata";
import { container } from "tsyringe";
import { Tokens } from "./tokens";
import { AuthRepository } from "~/features/auth/infrastructure/repositories/auth_repository";
import { OnboardingRepository } from "~/features/onboarding/infrastructure/repositories/onboarding_repository";

container.register(Tokens.IAuthRepository, { useClass: AuthRepository });
container.register(Tokens.IOnboardingRepository, { useClass: OnboardingRepository });

export { container };
