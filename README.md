# Lexavra Gaming - Flutter Take-Home Assignment

Lexavra Gaming is a small Flutter virtual gaming app made for Lexavra Infinology Pvt Ltd. It uses **Game Coins** only. There is no real money, payment system, crypto, or backend.

## Setup & Run

### Requirements

- Flutter 3.38.5 and Dart 3.10.4 were used to verify this project.
- The project Dart SDK constraint is `^3.10.4`.
- A Flutter emulator or device is required.
- Java 17 is required for Android builds.

The repository includes Android and iOS projects. The iOS deployment target is iOS 13.0.

From a clean clone, run:

```bash
flutter pub get
flutter run
```

To create a debug Android APK:

```bash
flutter build apk --debug
```

The generated APK is placed in `build/app/outputs/flutter-apk/`.

## Games

| Game | Status | Details |
| --- | --- | --- |
| Dice | Complete | A user can place a bet, choose Roll Over or Roll Under, see the result, receive winnings when applicable, and view the bet in history. |
| Other games | Not implemented | This submission focuses on one complete Dice game. |

## Dice Rules

- A roll is an integer from **1 to 100**.
- The target must be from **2 to 98**.
- **Roll Over** wins when the roll is greater than the target.
- **Roll Under** wins when the roll is less than the target.
- Win chance is based on the selected target.
- Multiplier is `100 / win chance`.
- On a win, payout is `floor(bet × multiplier)`.
- The bet is deducted first. The payout is added only when the user wins.

The Dice logic uses `Random(seed)`. The Dice controller uses the current microsecond timestamp as the seed, while the game class accepts a seed so its behavior can be tested deterministically.

## Key Design Decisions

### State Management

The app uses **GetX** for:

- Controllers and reactive state with `.obs` and `Obx`.
- Dependency injection with `Get.put` and `Get.find`.
- Named navigation with `GetMaterialApp`, `GetPage`, and `Get.offAllNamed`.
- Route bindings for the Home, Dice, and History screens.

`LocalStorage`, `WalletService`, and `AuthController` are app-wide dependencies. Screen-specific controllers are created through route bindings.

### Persistence

The app uses **Hive** through `LocalStorage`.

- `user_box` stores the local user profile and session state.
  - User: ID, username, and balance.
  - Session: whether the user is currently logged in.
- `bets_box` stores bet history.
  - Bet amount, game name, win/loss result, resulting balance, ID, and timestamp.

The balance and bet history stay on the device after an app restart. Logging out clears only the saved session state; it does not remove the local user, wallet balance, or bet history.

### Wallet Consistency

The stored Hive balance is the source of truth.

1. `WalletService.placeBet` validates the amount and available balance, then saves the deducted balance.
2. `DiceGame` creates the result.
3. `WalletService.add` saves the payout when the user wins.
4. The controller reads the stored balance and records the completed bet in history.
5. `WalletController` reloads the balance for the UI.

Invalid, zero, negative, and insufficient bets are rejected before coins move. Rapid taps are protected in two places:

- `DiceController.isRolling` prevents another roll while one is running.
- `WalletService` blocks overlapping `placeBet` calls with an in-memory transaction flag.

This is suitable for a local take-home app. It is not a crash-safe database transaction: an unexpected storage failure between deduction, payout, and history recording could leave a partial local update. A production system would need stronger transaction handling and server-authoritative outcomes.

## Architecture

```text
Pages
  -> GetX Controllers
    -> DiceGame / WalletService
      -> LocalStorage
        -> Hive
```

- `lib/presentation/` contains pages, controllers, and route bindings.
- `lib/domain/games/` contains the pure Dice rules and payout calculation.
- `lib/domain/services/` contains wallet operations and ledger recording.
- `lib/data/local/` contains Hive storage access.
- `lib/routes/` contains app bindings and named routes.
- `lib/theme/` contains the shared Material 3 theme.

## Authentication & Session

Authentication is local and username-based.

- A new local user gets 1,000 Game Coins.
- Login saves an active session in Hive.
- The splash screen opens Home only when both a saved user and active session exist.
- Logout removes the active session only.
- After logout and restart, the app opens Login; signing in again keeps the same wallet balance and history.
- When the app restarts with an active session, it restores Home with the saved balance and history.

## Testing

The current test suite contains **19 tests**.

- Dice unit tests cover deterministic seeded results, roll range, and invalid bet/target values.
- WalletService unit tests cover starting balance, deductions, winnings, validation, insufficient balance, persistence, ledger saving, and concurrent bet protection.
- The wallet tests use temporary Hive storage, so they do not use real app data.
- A basic widget smoke test verifies that Flutter widget tests can render the app title.

Verified results:

```text
flutter test    # 19 tests passed
flutter analyze # No issues found
```

## Verification

The application has been verified with:

- `flutter analyze` — no issues found.
- `flutter test` — 19 tests passed.
- Android 15 physical device.
- iOS simulator.
- Debug APK build and installation.
- Release APK build.
- Wallet persistence across logout and app restart.
- Bet history persistence across logout and app restart.
- Session restoration behavior.

## What I Would Do With More Time

1. Add integration tests for login, logout, session restore, and the full Dice-to-history flow.
2. Make wallet and history writes more resilient to unexpected storage failures.
3. Add a provably fair seed/nonce flow or server-authoritative results for a production version.
4. Add another virtual game only after keeping the Dice flow equally well tested.
5. Improve accessibility and add optional polish such as haptics or sound.

## Scope & Limitations

This take-home intentionally includes one complete local Dice game. It does not include real-money payments, backend authentication, multiple user accounts, server-side outcomes, provably fair verification, or a second game.
