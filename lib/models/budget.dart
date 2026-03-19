/// Budget model for expense tracking with monthly limits
class Budget {
  final String id;
  final String categoryName;
  final double limitAmount;
  final int month; // 1-12
  final int year;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this budget with modified fields
  Budget copyWith({
    String? id,
    String? categoryName,
    double? limitAmount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Budget(id: $id, category: $categoryName, limit: $limitAmount, $month/$year)';
}
