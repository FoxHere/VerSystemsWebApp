# AGENT.md - Ver Systems Web 2025

## Commands
- Build: `fvm flutter build web`
- Test: `fvm flutter test` (no tests currently exist)
- Analyze: `fvm flutter analyze`
- Run: `fvm flutter run -d chrome`
- Generate code: `fvm flutter packages pub run build_runner build`
- Clean: `fvm flutter clean && fvm flutter pub get`

## Architecture
Clean Architecture + MVVM with GetX for state management and dependency injection.
- Domain: `lib/data/models/` - Domain models organized by feature (user, task, activity, etc.)
- Data: `lib/data/services/` & `lib/data/repositories/` - Firebase services and repository pattern
- Presentation: `lib/ui/modules/` - Feature modules with MVVM pattern
- Config: `lib/Config/` - Controllers, routes, guards, and utilities
- Dependencies: `lib/Config/utils/init_dependencies.dart` - GetX DI configuration

## Code Style
- Line width: 100 characters (analysis_options.yaml)
- Imports: External packages first, then relative imports
- Naming: camelCase for variables/methods, PascalCase for classes
- Error handling: Either<Exception, T> pattern with RepositoryException/ServiceException
- State management: GetX controllers with .obs for reactive variables
- Comments: Minimal; Portuguese comments in existing code
- Firebase: Uses emulators in debug mode (localhost:8080, 9199, 9099)
- Models: Use .fromJson()/.toJson() methods for serialization
