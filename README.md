# Lexavra Gaming - Flutter Take-Home Assignment

Lexavra Gaming is a Flutter virtual gaming application built for the **Lexavra Infinology Pvt Ltd** take-home assignment.

The application uses **virtual Game Coins only**. It does not include real-money payments, payment processing, cryptocurrency, or backend integration.

## Setup & Run

### Requirements

- Flutter 3.38.5
- Dart 3.10.4
- Flutter SDK compatible with the project's Dart SDK constraint: `^3.10.4`
- A configured Android device/emulator or iOS simulator
- Java 17 for Android builds

The repository includes Android and iOS runner projects.

- Android is configured to use Java 17.
- iOS deployment target is iOS 13.0.

### Run from a clean clone

```bash
flutter pub get
flutter run
```

### Build Android APK

To create a debug APK:

```bash
flutter build apk --debug
```

The generated APK is placed at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Games

| Game | Status | Details |
| --- | --- | --- |
| Dice | Complete | Supports configurable bets, Roll Over/Roll Under predictions, target values, results, multipliers, payouts, wallet updates, and history. |
| Coin Flip | Complete | Supports Heads/Tails predictions, configurable bets, 2x payouts, wallet updates, results, and history. |
| Other games | Not implemented | No additional games are included in this submission. |

The assignment focuses on delivering complete, tested implementations of Dice and Coin Flip rather than partially implementing several games.

## Dice Rules

- The roll is an integer from **1 to 100**.
- The target must be between **2 and 98**.
- **Roll Over** wins when `roll > target`.
- **Roll Under** wins when `roll < target`.
- Win chance depends on the selected target and prediction.
- Multiplier is calculated as:

```text
100 / win chance
```

- On a win, payout is:

```text
floor(bet × multiplier)
```

- The bet amount is deducted before the game result is applied.
- If the player wins, the calculated payout is credited to the wallet.

The Dice game uses `Random(seed)` for its local outcome generation. The controller supplies the current microsecond timestamp as the seed during normal play, while the game logic accepts an explicit seed so deterministic outcomes can be tested.

This is a local seeded RNG implementation and is **not a provably-fair system**.

## Coin Flip Rules

- The player chooses **Heads** or **Tails**.
- A coin result is generated as either Heads or Tails.
- A correct prediction wins.
- A winning bet receives a **2x payout**.
- The original bet is deducted before the result is applied.
- On a win, the payout is credited to the wallet.
- The completed result is recorded in bet history.

Coin Flip logic is implemented separately from the UI and controller so the game rules remain independent of Flutter presentation code.

## Key Design Decisions

### State Management

The application uses **GetX** for state management, dependency injection, and navigation.

GetX is used for:

- Reactive state with `Rx` values and `Obx`.
- Dependency injection with `Get.put` and `Get.find`.
- Named navigation with `GetMaterialApp` and `GetPage`.
- Route-specific dependency bindings.
- Navigation between login, home, Dice, Coin Flip, and history screens.

The application separates responsibilities between:

- Pages for UI rendering and user interaction.
- Controllers for coordinating UI state and application flows.
- Domain game classes for game rules.
- `WalletService` for wallet mutations and bet recording.
- `LocalStorage` for Hive persistence.

App-wide dependencies such as `LocalStorage`, `WalletService`, and `AuthController` are registered through application bindings. Game-specific controllers are created through route bindings.

### Persistence

The application uses **Hive** for local persistence through a `LocalStorage` abstraction.

Two Hive boxes are used:

```text
user_box
bets_box
```

`user_box` stores:

- User ID
- Username
- Wallet balance
- Local session state

`bets_box` stores:

- Bet ID
- Bet amount
- Game name
- Win/loss result
- Resulting balance
- Creation timestamp

The persisted wallet balance remains available after an application restart.

Bet history is stored separately from the current session, allowing previous bets to remain available after logout and subsequent login.

### Wallet Consistency

The persisted wallet balance is the **source of truth**.

The main wallet flow is:

```text
User places bet
       ↓
WalletService validates bet
       ↓
Bet amount is deducted and persisted
       ↓
Game generates result
       ↓
If won → payout is credited and persisted
       ↓
Resulting balance is read
       ↓
Bet is recorded in history
       ↓
WalletController reflects the persisted balance
```

`WalletService.placeBet()` validates:

- Positive bet amount
- Existing user
- Sufficient balance

The wallet cannot become negative through a normal bet.

Rapid or overlapping bet attempts are protected at two levels:

- `DiceController.isRolling` / `CoinController.isFlipping` prevents concurrent game actions from the UI.
- `WalletService` uses an in-memory transaction guard to prevent overlapping wallet deductions.

This approach is appropriate for a local take-home application. It is **not a crash-safe atomic transaction**. A production implementation would require stronger transactional guarantees, recovery handling, and server-authoritative wallet/game operations.

## Architecture

The project follows a lightweight separation of presentation, domain logic, services, and local persistence.

```text
Presentation
    │
    ├── Pages
    ├── Controllers
    └── Bindings
          │
          ▼
Domain
    │
    ├── DiceGame
    ├── CoinGame
    └── WalletService
          │
          ▼
Data
    │
    └── LocalStorage
          │
          ▼
        Hive
```

### Main project structure

```text
lib/
├── data/
│   └── local/
│       └── local_storage.dart
│
├── domain/
│   ├── games/
│   │   ├── dice_game.dart
│   │   └── coin_game.dart
│   └── services/
│       └── wallet_service.dart
│
├── presentation/
│   ├── bindings/
│   ├── controllers/
│   ├── pages/
│   │   ├── coin/
│   │   ├── dice/
│   │   ├── history/
│   │   ├── home/
│   │   ├── login/
│   │   └── splash/
│   └── widgets/
│       └── game_card.dart
│
├── routes/
└── theme/
```

The UI also uses a shared `GameCard` widget for the Dice and Coin Flip entries on the Home screen.

Game-specific result sections remain private to their respective pages because Dice and Coin Flip have different result data and presentation requirements.

## Authentication & Session

Authentication is intentionally local and username-based because the assignment does not require a backend authentication system.

### New user

A new local user starts with:

```text
1000 Game Coins
```

### Login

When a user logs in:

1. The local user is created or loaded.
2. The active session is persisted.
3. The application navigates to Home.

### App restart

The splash screen checks the persisted local session.

If an active session and saved user exist:

```text
Splash → Home
```

Otherwise:

```text
Splash → Login
```

### Logout

Logging out clears the active session but does **not** delete:

- The local user
- Wallet balance
- Bet history

Therefore, logging in again with the same local user preserves the wallet and history.

## Testing

The current test suite contains **25 tests**.

### Dice tests

Dice unit tests cover:

- Deterministic seeded results
- Valid roll range
- Invalid bet values
- Invalid target values
- Dice game outcome behavior

### Coin Flip tests

Coin Flip tests cover:

- Coin result behavior
- Heads/Tails predictions
- Payout behavior
- Invalid bet handling

### Wallet tests

`WalletService` tests cover:

- Starting balance
- Bet deductions
- Payout/credits
- Zero and negative bet validation
- Insufficient balance handling
- Prevention of negative balances
- Persisted balance changes
- Persisted bet records
- Concurrent bet protection

Wallet tests use temporary Hive storage and do not use the application's real local data.

### Widget test

A basic Flutter widget test verifies that the application test infrastructure can render the app successfully.

### Verified results

```text
flutter analyze
```

```text
No issues found!
```

```text
flutter test
```

```text
25 tests passed
```

## Verification

The application was verified through both automated and manual testing.

### Automated

- `flutter analyze` — no issues found
- `flutter test` — 25 tests passed

### Manual

The application was tested on:

- Android 15 physical device
- iOS simulator

The following flows were verified:

- Local username login
- Session restoration
- Logout
- Login after logout
- Wallet persistence across application restart
- Bet history persistence
- Dice gameplay
- Coin Flip gameplay
- Wallet updates after bets
- Insufficient balance handling
- Input validation
- Rapid bet protection
- Navigation between Home, games, and History

A debug Android APK was also successfully built and installed on the physical Android device.

## What I Would Do With More Time

1. Add integration tests covering the complete login, session restoration, gameplay, wallet, and history flows.
2. Add richer widget tests for validation, loading states, error presentation, and rapid user interactions.
3. Make wallet and history updates more resilient to unexpected local storage failures.
4. Replace local timestamp-seeded randomness with a provably-fair seed/nonce mechanism or server-authoritative game outcomes for a production system.
5. Add more virtual games while maintaining the same level of testing and wallet consistency.
6. Improve accessibility, responsive behavior, and additional UI polish such as optional haptics and sound.

## Scope & Limitations

This is a local virtual gaming take-home application.

It intentionally does **not** include:

- Real-money payments
- Payment processing
- Cryptocurrency
- Backend authentication
- Multiple remote user accounts
- Server-side wallet management
- Server-authoritative game outcomes
- Provably-fair verification
- Additional games beyond Dice and Coin Flip

The current implementation is designed to demonstrate Flutter development, GetX state management, local persistence, separation of responsibilities, game logic, wallet handling, and testing within the scope of the take-home assignment.