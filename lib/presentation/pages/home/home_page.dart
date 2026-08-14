import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/game_card.dart';

class HomePage extends GetView<WalletController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lexavra Gaming',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authController.logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Obx(
              () => Text(
                'Welcome, ${authController.username.value}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ready to play?',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // Wallet
            Obx(
              () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Game Coins',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.balance.value}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Games',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            // Dice game
            GameCard(
              icon: Icons.casino_rounded,
              title: 'Dice',
              subtitle: 'Roll over or under your target',
              onTap: () => Get.toNamed('/dice'),
            ),
            const SizedBox(height: 8),
            GameCard(
              icon: Icons.toll_rounded,
              title: 'Coin Flip',
              subtitle: 'Pick heads or tails and flip the coin',
              onTap: () => Get.toNamed('/coin'),
            ),
            const SizedBox(height: 24),

            // History
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/history'),
              icon: const Icon(Icons.history_rounded),
              label: const Text('Bet History'),
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                'Virtual coins only • No real money',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
