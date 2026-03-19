import 'package:flutter/material.dart';

class ExchangeRateCard extends StatelessWidget {
  const ExchangeRateCard({
    super.key,
    required this.rate,
    required this.errorMessage,
    required this.onRefresh,
  });

  final double? rate;
  final String? errorMessage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.currency_exchange, size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USD/VND',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    rate != null
                        ? rate!.toStringAsFixed(2)
                        : (errorMessage ?? 'Đang tải...'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: errorMessage != null
                              ? Theme.of(context).colorScheme.error
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới tỷ giá',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
