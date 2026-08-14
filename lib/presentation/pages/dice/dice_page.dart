import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../controllers/dice_controller.dart';
import '../../controllers/wallet_controller.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  late final TextEditingController _betController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();

    _betController = TextEditingController(text: '10');
    _targetController = TextEditingController(text: '50');
  }

  @override
  void dispose() {
    _betController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiceController>();
    final walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dice',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Wallet
            Obx(
              () => Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${walletController.balance.value} coins',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Place your bet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            Text(
              'Choose a target and predict whether the roll will be above or below it.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _betController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bet Amount',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target (2 - 98)',
                prefixIcon: Icon(Icons.track_changes_rounded),
              ),
            ),

            const SizedBox(height: 14),

            Obx(
              () => DropdownButtonFormField<bool>(
                initialValue: controller.rollOver.value,
                decoration: const InputDecoration(
                  labelText: 'Prediction',
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: true, child: Text('Roll Over')),
                  DropdownMenuItem(value: false, child: Text('Roll Under')),
                ],
                onChanged: controller.isRolling.value
                    ? null
                    : (value) {
                        if (value != null) {
                          controller.setPrediction(value);
                        }
                      },
              ),
            ),

            const SizedBox(height: 20),

            // Roll button
            Obx(
              () => SizedBox(
                height: AppTheme.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: controller.isRolling.value
                      ? null
                      : () => _roll(context, controller),
                  icon: controller.isRolling.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.casino_rounded),
                  label: Text(
                    controller.isRolling.value ? 'Rolling...' : 'Roll Dice',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Obx(() {
              final gameResult = controller.result.value;

              if (gameResult == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.casino_outlined,
                          size: 42,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your result will appear here',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final resultColor = gameResult.won
                  ? AppTheme.success
                  : AppTheme.error;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        gameResult.won ? 'YOU WON' : 'YOU LOST',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: resultColor,
                              letterSpacing: 0.5,
                            ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '${gameResult.roll}',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        gameResult.won
                            ? 'Payout: ${gameResult.payout} coins'
                            : 'Better luck next time.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Multiplier: '
                        '${gameResult.multiplier.toStringAsFixed(2)}x',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _roll(BuildContext context, DiceController controller) async {
    final bet = int.tryParse(_betController.text);
    final target = int.tryParse(_targetController.text);

    if (bet == null || target == null) {
      _showError(context, 'Enter valid numbers.');
      return;
    }

    final error = await controller.roll(bet: bet, target: target);

    if (error != null && context.mounted) {
      _showError(context, error);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
