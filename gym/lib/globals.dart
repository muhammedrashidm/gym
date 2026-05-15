import 'theme/theme_manager.dart';
export 'theme/theme_manager.dart';

/// Global ThemeManager instance — shared across the app.
/// Declared here so it's accessible from any widget without DI.
final themeManager = ThemeManager();
