import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/games/coin_game.dart';
import '../../../theme/app_theme.dart';
import '../../controllers/coin_controller.dart';
import '../../controllers/wallet_controller.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  late final TextEditingController _betController;

  @override
  void initState() {
    super.initState();

    _betController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _betController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoinController>();
    final walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coin Flip',
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
              'Choose Heads or Tails and predict the result of the coin flip.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            // Bet amount
            TextField(
              controller: _betController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bet Amount',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),

            const SizedBox(height: 14),

            // Prediction
            Obx(
              () => DropdownButtonFormField<CoinSide>(
                initialValue: controller.prediction.value,
                decoration: const InputDecoration(
                  labelText: 'Prediction',
                  prefixIcon: Icon(Icons.toll_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: CoinSide.heads, child: Text('Heads')),
                  DropdownMenuItem(value: CoinSide.tails, child: Text('Tails')),
                ],
                onChanged: controller.isFlipping.value
                    ? null
                    : (value) {
                        if (value != null) {
                          controller.setPrediction(value);
                        }
                      },
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Win payout: 2x your bet',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            // Flip button
            Obx(
              () => SizedBox(
                height: AppTheme.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: controller.isFlipping.value
                      ? null
                      : () => _flip(context, controller),
                  icon: controller.isFlipping.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.toll_rounded),
                  label: Text(
                    controller.isFlipping.value ? 'Flipping...' : 'Flip Coin',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            _CoinResultSection(controller: controller),
          ],
        ),
      ),
    );
  }

  Future<void> _flip(BuildContext context, CoinController controller) async {
    final bet = int.tryParse(_betController.text);

    if (bet == null) {
      _showError(context, 'Enter a valid bet amount.');
      return;
    }

    final error = await controller.flip(bet: bet);

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

class _CoinResultSection extends StatelessWidget {
  final CoinController controller;

  const _CoinResultSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gameResult = controller.result.value;

      if (gameResult == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Icon(
                  Icons.toll_outlined,
                  size: 42,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your result will appear here',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }

      final resultText = gameResult.result == CoinSide.heads
          ? 'HEADS'
          : 'TAILS';

      final predictionText = gameResult.prediction == CoinSide.heads
          ? 'Heads'
          : 'Tails';

      final resultColor = gameResult.won ? AppTheme.success : AppTheme.error;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                gameResult.won ? 'YOU WON' : 'YOU LOST',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: resultColor,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                resultText,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your prediction: $predictionText',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 12),

              Text(
                gameResult.won
                    ? 'Payout: ${gameResult.payout} coins'
                    : 'Better luck next time.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 6),

              Text(
                'Multiplier: 2.00x',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    });
  }
}
