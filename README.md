# Context-Aware Recipe Discovery

A production-style Flutter assignment app for discovering recipes from TheMealDB with search, contextual recommendations, offline favorites, cached images, location-based cuisine suggestions, and meal reminder notifications.

The project is intentionally built with a feature-first architecture so it stays easy to finish, review, and extend within a two-day assignment window.

## Tech Stack

- Flutter stable
- Riverpod for state management
- GoRouter for navigation
- Dio for API calls
- Hive for local offline storage
- CachedNetworkImage for image caching
- Geolocator and Geocoding for location-based cuisine suggestions
- Flutter Local Notifications for meal reminders
- Shimmer for polished loading states

## Features Implemented

- Recipe search using TheMealDB
- Debounced search input
- Recipe list and details screen
- Hero image animation
- Favorite button animation
- Favorites stored locally with Hive
- Previously viewed recipe details cached offline
- Cached recipe images
- Location-based cuisine recommendations
- Time-based meal recommendations
- Breakfast, lunch, and dinner local notifications
- Empty, loading, error, and no-internet states

## API Used

The app uses TheMealDB public API:

```text
https://www.themealdb.com/api/json/v1/1
```

Main endpoints:

```text
/search.php?s={query}
/lookup.php?i={mealId}
/filter.php?a={area}
/filter.php?c={category}
/categories.php
```

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── network/
│   │   ├── dio_provider.dart
│   │   └── network_exception.dart
│   ├── services/
│   │   ├── app.dart
│   │   ├── app_router.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_error_view.dart
│       ├── app_placeholder.dart
│       ├── app_shimmer.dart
│       └── cached_recipe_image.dart
│
├── features/
│   ├── recipes/
│   │   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── favorites/
│   │   ├── data/
│   │   ├── providers/
│   │   └── repositories/
│   ├── location/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── services/
│   │   └── utils/
│   └── notifications/
│       ├── models/
│       ├── providers/
│       └── services/
│
└── main.dart
```

## App Startup Flow

The app starts in `main.dart`.

```text
main.dart
 -> WidgetsFlutterBinding.ensureInitialized()
 -> Hive.initFlutter()
 -> open favorites Hive box
 -> open viewed recipes Hive box
 -> initialize NotificationService
 -> run ProviderScope
 -> RecipeDiscoveryApp
```

`RecipeDiscoveryApp` is defined in:

```text
lib/core/services/app.dart
```

It creates `MaterialApp.router`, applies the app theme, and uses the Riverpod-powered GoRouter from:

```text
lib/core/services/app_router.dart
```

## Navigation Flow

Navigation is handled by GoRouter.

Routes:

```text
/              -> HomeScreen
/recipes/:id   -> RecipeDetailsScreen
/favorites     -> FavoritesScreen
/notifications -> NotificationsScreen
/location      -> LocationScreen
```

The Home screen can navigate to:

- Favorites
- Cuisine Near You
- Meal Reminders
- Recipe Details

## Recipe Data Flow

The recipe feature follows this flow:

```text
UI
 -> Riverpod provider
 -> RecipeRepository
 -> MealDbRecipeRepository
 -> MealDbApiService
 -> Dio
 -> TheMealDB API
```

Key files:

```text
lib/features/recipes/data/meal_db_api_service.dart
lib/features/recipes/repositories/recipe_repository.dart
lib/features/recipes/repositories/meal_db_recipe_repository.dart
lib/features/recipes/providers/recipe_providers.dart
```

`MealDbApiService` contains direct API calls only. It does not know about UI.

`RecipeRepository` defines the contract.

`MealDbRecipeRepository` implements the contract using TheMealDB.

`recipe_providers.dart` exposes data to the UI through Riverpod.

## Search Flow

The search UI lives in:

```text
lib/features/recipes/screens/home_screen.dart
lib/features/recipes/widgets/recipe_search_bar.dart
```

Flow:

```text
User types query
 -> HomeScreen waits 450ms
 -> recipeSearchProvider(query)
 -> repository.searchRecipes(query)
 -> MealDbApiService.searchRecipes(query)
 -> /search.php?s={query}
 -> HomeScreen renders list, empty state, loading state, or error state
```

If the query is empty, the app loads initial recipes:

```text
initialRecipesProvider
 -> searchRecipes('')
```

## Recipe Details Flow

The list item passes the selected recipe as `extra` while navigating to details.

```text
RecipeCard tap
 -> GoRouter /recipes/:id
 -> RecipeDetailsScreen
```

The details screen still fetches full data by ID because list and filter API responses can be partial.

```text
RecipeDetailsScreen
 -> recipeDetailsProvider(id)
 -> repository.fetchRecipeById(id)
 -> /lookup.php?i={id}
```

When full recipe details load successfully, the app stores them in Hive as a previously viewed recipe.

If the network fails later, the provider falls back to the cached viewed recipe.

## Favorites Flow

Favorites are stored locally with Hive.

Key files:

```text
lib/features/favorites/data/recipe_local_data_source.dart
lib/features/favorites/repositories/favorites_repository.dart
lib/features/favorites/repositories/hive_favorites_repository.dart
lib/features/favorites/providers/favorites_providers.dart
```

Flow:

```text
Favorite button tap
 -> favoriteRecipesProvider.notifier.toggleFavorite(recipe)
 -> HiveFavoritesRepository
 -> RecipeLocalDataSource
 -> Hive box: favorite_recipes
```

The favorites screen reads from:

```text
favoriteRecipesProvider
```

Favorites are available offline because the full recipe data is serialized into Hive.

## Offline-First Flow

The app supports offline use in three ways:

1. Favorite recipes are saved in Hive.
2. Viewed recipe details are cached in Hive.
3. Network images are cached using CachedNetworkImage.

Viewed recipe fallback:

```text
recipeDetailsProvider(id)
 -> try API lookup
 -> if API succeeds, cache recipe
 -> if API fails, read viewed_recipes Hive box
 -> if cached recipe exists, show it offline
 -> otherwise show error state
```

Storage keys are defined in:

```text
lib/core/constants/storage_keys.dart
```

## Image Caching Flow

All recipe images use:

```text
lib/core/widgets/cached_recipe_image.dart
```

This wraps `CachedNetworkImage` and provides:

- Disk-backed image cache
- Loading shimmer
- Empty URL fallback
- Error fallback
- Smooth fade-in

Used by:

```text
RecipeCard
CompactRecipeTile
RecipeDetailsScreen
```

## Location-Based Cuisine Flow

Location feature files:

```text
lib/features/location/services/location_service.dart
lib/features/location/utils/cuisine_area_mapper.dart
lib/features/location/providers/location_providers.dart
lib/features/location/location_screen.dart
```

Flow:

```text
locationCuisineContextProvider
 -> LocationService.getCuisineContext()
 -> check location service
 -> request permission if needed
 -> get device coordinates
 -> reverse geocode coordinates
 -> get country and country code
 -> CuisineAreaMapper maps country to TheMealDB area
 -> locationRecipesProvider fetches /filter.php?a={area}
```

Examples:

```text
IN -> Indian
US -> American
GB -> British
JP -> Japanese
```

The Home screen shows a compact location recommendation rail when search is empty.

The full location page is available at:

```text
/location
```

## Time-Based Recommendation Flow

Time-based recommendation logic lives in:

```text
lib/features/recipes/models/meal_time_suggestion.dart
lib/features/recipes/providers/recipe_providers.dart
```

Flow:

```text
currentDateTimeProvider
 -> mealTimeSuggestionProvider
 -> mealTimeRecipesProvider
 -> /filter.php?c={category}
```

Mapping:

```text
5:00 AM - 11:59 AM  -> Breakfast -> Breakfast category
12:00 PM - 4:59 PM  -> Lunch     -> Vegetarian category
5:00 PM onward      -> Dinner    -> Seafood category
```

TheMealDB does not provide native Lunch and Dinner categories, so category-backed recommendations are used for those meal windows.

## Notification Flow

Notification feature files:

```text
lib/features/notifications/models/meal_reminder.dart
lib/features/notifications/services/notification_service.dart
lib/features/notifications/providers/notification_providers.dart
lib/features/notifications/notifications_screen.dart
```

Startup:

```text
main.dart
 -> NotificationService().initialize()
 -> configure timezone
 -> initialize FlutterLocalNotificationsPlugin
```

Scheduling:

```text
NotificationsScreen
 -> notificationControllerProvider.notifier.scheduleMealReminders()
 -> NotificationService.requestPermissions()
 -> cancel old reminders
 -> schedule daily reminders
```

Reminder times:

```text
Breakfast -> 8:00 AM
Lunch     -> 2:00 PM
Dinner    -> 8:00 PM
```

The app uses timezone-aware scheduling through the `timezone` and `flutter_timezone` packages.

Android uses:

```text
AndroidScheduleMode.inexactAllowWhileIdle
```

This avoids unnecessary exact alarm complexity while still scheduling daily meal reminders.

## Error, Empty, and Loading States

Shared UI widgets:

```text
lib/core/widgets/app_error_view.dart
lib/core/widgets/app_placeholder.dart
lib/core/widgets/app_shimmer.dart
```

Used for:

- Home recipe loading
- Details loading
- Location loading
- Empty search results
- Empty favorites
- No-internet fallback
- API errors

Network errors are normalized in:

```text
lib/core/network/network_exception.dart
```

If the error looks like a connectivity issue, the app shows a no-internet message and reminds the user that favorites and viewed recipes still work offline.

## Platform Permissions

Android permissions are configured in:

```text
android/app/src/main/AndroidManifest.xml
```

Used for:

- Location
- Notifications
- Boot completed receiver for scheduled notifications

iOS location permission text is configured in:

```text
ios/Runner/Info.plist
```

## Setup Instructions

Install dependencies:

```bash
flutter pub get
```

Run analyzer:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the app:

```bash
flutter run
```

Build APK:

```bash
flutter build apk --release
```

## GitHub Actions CI/CD

The CI workflow is defined in:

```text
.github/workflows/flutter-ci-release.yml
```

It runs automatically on:

- Pull requests to `main` or `master`
- Pushes to `main` or `master`
- Version tags like `v1.0.0`
- Manual dispatch from the GitHub Actions tab

Workflow steps:

```text
Checkout repository
 -> set up Java 17
 -> set up Flutter stable
 -> flutter pub get
 -> flutter analyze
 -> flutter test
 -> flutter build apk --release
 -> upload APK as workflow artifact
 -> publish GitHub Release when the push is a v* tag
```

For normal pushes and pull requests, the generated APK is available as a workflow artifact named:

```text
recipe-discovery-apk
```

To create a GitHub Release with the APK attached:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will build:

```text
release/recipe-discovery-v1.0.0.apk
```

and attach it to the generated GitHub Release.

Note: the current Android release build uses the debug signing config from the default Flutter scaffold. This is fine for assignment review APKs, but a production Play Store release should use a private upload keystore.

## Testing

Current tests cover:

- Recipe parsing from TheMealDB payloads
- Recipe local serialization for Hive storage
- Country-to-cuisine mapping
- Time-based meal suggestion mapping
- App shell rendering with provider overrides

Run:

```bash
flutter test
```

## Important Design Choices

- Feature-first architecture keeps each requirement isolated.
- Riverpod providers expose state and async loading cleanly.
- Repository layer keeps UI independent from API details.
- Hive is used directly with JSON maps to avoid code generation overhead.
- CachedNetworkImage handles offline-friendly image reuse.
- Previously viewed recipes are cached so details can open offline.
- Notification scheduling uses inexact daily reminders for Android compatibility.
- The app avoids authentication, Firebase, Supabase, and unnecessary complexity.

## Assignment Status

Implemented:

- Step 1: Project setup, dependencies, Riverpod, GoRouter
- Step 2: Models, Dio API service, repository
- Step 3: Home screen, recipe list, debounced search
- Step 4: Recipe details, hero animation, favorite animation
- Step 5: Hive favorites and viewed recipe cache
- Step 6: Cached images
- Step 7: Location-based cuisine suggestions
- Step 8: Time-based recommendations
- Step 9: Local notifications
- Step 10: Shimmer, error, empty, no-internet states
- Step 11: GitHub Actions CI/CD and APK release workflow

