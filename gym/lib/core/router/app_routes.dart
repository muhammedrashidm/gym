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
  staff(path: '/staff', name: 'staff');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}
