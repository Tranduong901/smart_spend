import 'package:flutter/material.dart';

class CustomKeypad extends StatelessWidget {
  final void Function(String) onInput;
  final void Function() onBackspace;

  const CustomKeypad({
    super.key,
    required this.onInput,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children:
                  List.generate(9, (i) => (i + 1).toString()).map((label) {
                      return TextButton(
                        onPressed: () => onInput(label),
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    }).toList()
                    ..add(
                      TextButton(
                        onPressed: () => onInput('0'),
                        child: const Text('0', style: TextStyle(fontSize: 24)),
                      ),
                    )
                    ..add(
                      TextButton(
                        onPressed: onBackspace,
                        child: const Icon(Icons.backspace),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
