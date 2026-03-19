import 'package:flutter/material.dart';

class ReceiptCaptureButton extends StatelessWidget {
  const ReceiptCaptureButton({
    super.key,
    required this.hasReceipt,
    required this.onCapture,
  });

  final bool hasReceipt;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hóa đơn', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(hasReceipt ? 'Chụp lại ảnh hóa đơn' : 'Chụp ảnh hóa đơn'),
        ),
      ],
    );
  }
}
