class Limit {
  final String title;
  final String? tag; // category name to match transactions
  double? amount;

  Limit({required this.title, this.tag, this.amount});

  Map<String, dynamic> toMap() => {
        'title': title,
        'tag': tag,
        'amount': amount,
      };

  factory Limit.fromMap(Map<dynamic, dynamic> map) {
    return Limit(
      title: map['title'] as String? ?? '',
      tag: map['tag'] as String?,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
    );
  }
}
