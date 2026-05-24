# PizzaF Project Guide

PizzaF is a monorepo with three Dart packages:

- `client/` - Flutter app
- `server/` - Dart Shelf API server
- `shared/` - shared models and request/response DTOs

The Flutter client talks to the server over HTTP. The server currently stores users, tokens, menu data, and orders in memory, so data resets when the server restarts.

## Requirements

- Flutter SDK
- Dart SDK from Flutter
- A browser, emulator, simulator, or desktop target for running the Flutter app

## Install Dependencies

Run dependency installation once for each package:

```bash
cd /Users/avaz/StudioProjects/pizzaf/shared
dart pub get

cd /Users/avaz/StudioProjects/pizzaf/server
dart pub get

cd /Users/avaz/StudioProjects/pizzaf/client
flutter pub get
```

## Run The Server

Open a terminal and run:

```bash
cd /Users/avaz/StudioProjects/pizzaf/server
dart run bin/server.dart
```

The server listens on:

```text
http://0.0.0.0:8080
```

Keep this terminal running while using the Flutter app.

## Run The Flutter App

Open a second terminal.

For Chrome:

```bash
cd /Users/avaz/StudioProjects/pizzaf/client
flutter run -d chrome
```

For a web server on a fixed port:

```bash
cd /Users/avaz/StudioProjects/pizzaf/client
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5174
```

Then open:

```text
http://localhost:5174/
```

## API Connection

The client default API URL is:

```text
http://localhost:8080
```

For Android emulator, the client automatically uses:

```text
http://10.0.2.2:8080
```

To override the API URL, pass a Dart define:

```bash
flutter run -d chrome \
  --dart-define=PIZZAF_API_BASE_URL=http://localhost:8080
```

For a physical phone on the same Wi-Fi, use your computer's LAN IP:

```bash
flutter run \
  --dart-define=PIZZAF_API_BASE_URL=http://192.168.1.20:8080
```

## App Flow

1. Start the server.
2. Start the Flutter app.
3. Register a new user or log in.
4. The menu loads from `GET /pizzas/`.
5. Customize a half-and-half pizza.
6. Add it to cart.
7. Place an order with `POST /orders/`.
8. Track order status as the server simulates progress.

## Useful Commands

Analyze the client:

```bash
cd /Users/avaz/StudioProjects/pizzaf/client
flutter analyze
```

Run client tests:

```bash
cd /Users/avaz/StudioProjects/pizzaf/client
flutter test
```

Analyze the server:

```bash
cd /Users/avaz/StudioProjects/pizzaf/server
dart analyze
```

Analyze shared models:

```bash
cd /Users/avaz/StudioProjects/pizzaf/shared
dart analyze
```

Format all Dart code:

```bash
cd /Users/avaz/StudioProjects/pizzaf/client
dart format lib test

cd /Users/avaz/StudioProjects/pizzaf/server
dart format lib bin

cd /Users/avaz/StudioProjects/pizzaf/shared
dart format lib
```

## Package Responsibilities

### `shared/`

Contains data types used by both client and server:

- `User`
- `AuthTokens`
- `AuthResponse`
- `PizzaType`
- `PizzaInfo`
- `CartPizza`
- `Order`
- `LoginRequest`
- `RegisterRequest`
- `CreateOrderRequest`

Change shared API contracts here first, then update server and client together.

### `server/`

Contains:

- `bin/server.dart` - server entry point
- `lib/src/routes/` - HTTP route handlers
- `lib/src/services/` - business logic
- `lib/src/middleware/` - CORS, logging, auth middleware
- `lib/src/db/database.dart` - current in-memory storage

Important current behavior:

- Auth endpoints are public.
- `/pizzas/` and `/orders/` currently require trailing slashes.
- `/health` is currently protected by auth.
- Data is lost when the server process stops.

### `client/`

Contains:

- `main.dart` - manual dependency setup
- `app.dart` - app root and auth-state switching
- `core/api/` - API client and secure token storage
- `core/di/` - `InheritedWidget` dependency container
- `features/auth/` - login and registration
- `features/menu/` - pizza menu
- `features/customizer/` - half-and-half pizza builder
- `features/cart/` - cart and checkout
- `features/orders/` - order history and tracking
- `theme/` - app theme

The client uses `ChangeNotifier` and manual constructor injection. There is no `provider`, `get_it`, or generated DI.

## Known Limitations

- Server persistence is in-memory only.
- Server does not yet use Drift/SQLite.
- Restarting the server clears registered users, refresh tokens, and orders.
- Pizza images are drawn in Flutter with custom painters instead of loaded bitmap assets.
- Route paths currently use trailing slashes for menu and orders because of the current server router setup.

