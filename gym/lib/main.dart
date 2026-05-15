// Default entry point (dev flavor) — kept for IDE hot reload compatibility.
// Use main_dev.dart / main_staging.dart / main_prod.dart for flavor launches.
import 'bootstrap.dart';
import 'core/config/app_config.dart';

void main() => bootstrap(AppConfig.dev);
