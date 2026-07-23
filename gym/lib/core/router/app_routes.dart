enum AppRoute {
  splash(path: '/splash', name: 'splash'),
  login(path: '/login', name: 'login'),
  otp(path: '/otp', name: 'otp'),
  selectWorkspace(path: '/select-workspace', name: 'select-workspace'),
  member(path: '/member', name: 'member'),
  explore(path: '/member/explore', name: 'explore'),
  train(path: '/member/train', name: 'train'),
  recovery(path: '/member/recovery', name: 'recovery'),
  profile(path: '/member/profile', name: 'profile'),
  trainerSignup(path: '/trainer-signup', name: 'trainer-signup'),
  staff(path: '/staff', name: 'staff'),
  staffDashboard(path: '/staff/dashboard', name: 'staff-dashboard'),
  staffClients(path: '/staff/clients', name: 'staff-clients'),
  staffProfile(path: '/staff/profile', name: 'staff-profile'),
  staffQr(path: '/staff/qr', name: 'staff-qr'),
  staffAddClient(path: '/staff/register-client', name: 'staff-register-client'),
  clientScanner(path: '/member/scan-qr', name: 'client-scan-qr'),
  athleteWorkout(path: '/staff/clients/:clientId/workout', name: 'athlete-workout'),
  initiateProgram(path: '/staff/clients/:clientId/workout/create', name: 'initiate-program'),
  weekPlanCreator(path: '/staff/clients/:clientId/workout/workout-profile/:workoutProfileId/weekly-plan/new', name: 'week-plan-creator'),
  dayPlanCreator(path: '/staff/clients/:clientId/workout/weekly-plan/:weeklyPlanId/edit', name: 'day-plan-creator'),
  taskExecution(path: '/member/train/task-execution', name: 'task-execution'),
  watchMe(path: '/member/train/watch-me', name: 'watch-me'),
  staffLiveSessions(path: '/staff/live-sessions', name: 'staff-live-sessions'),
  clientSessionUpdate(path: '/staff/clients/:clientId/session', name: 'client-session-update'),
  dayPreview(path: '/day-preview', name: 'day-preview');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}
