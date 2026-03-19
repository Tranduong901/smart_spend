String formatCurrency(int value) {
  final sign = value < 0 ? '-' : '';
  final absValue = value.abs();
  final s = absValue.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    buffer.write(s[i]);
    if (pos > 1 && pos % 3 == 1) {
      buffer.write(',');
    }
  }
  // The above places commas incorrectly; simpler approach:
  final rev = s.split('').reversed.join();
  final groups = <String>[];
  for (var i = 0; i < rev.length; i += 3) {
    groups.add(rev.substring(i, (i + 3).clamp(0, rev.length)));
  }
  final joined = groups
      .map((g) => g.split('').reversed.join())
      .toList()
      .reversed
      .join(',');
  return '$sign$joined đ';
}
