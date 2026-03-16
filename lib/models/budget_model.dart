class BudgetModel {
  final int? id;
  final int? categoryId;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final String month; // YYYY-MM
  final String? color;

  BudgetModel({
    this.id,
    this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.month,
    this.color,
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get percentage => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentAmount > limitAmount;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num? ?? 0).toDouble(),
      month: map['month'] as String,
      color: map['color'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'month': month,
      'color': color,
    };
  }
}
