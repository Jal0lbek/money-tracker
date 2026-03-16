class RecurringModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // kirim, chiqim
  final int? accountId;
  final int? categoryId;
  final int dayOfMonth;
  final bool isActive;
  final String? lastExecuted;
  final String createdAt;

  RecurringModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.accountId,
    this.categoryId,
    required this.dayOfMonth,
    this.isActive = true,
    this.lastExecuted,
    required this.createdAt,
  });

  factory RecurringModel.fromMap(Map<String, dynamic> map) {
    return RecurringModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      accountId: map['account_id'] as int?,
      categoryId: map['category_id'] as int?,
      dayOfMonth: map['day_of_month'] as int,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      lastExecuted: map['last_executed'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'account_id': accountId,
      'category_id': categoryId,
      'day_of_month': dayOfMonth,
      'is_active': isActive ? 1 : 0,
      'last_executed': lastExecuted,
      'created_at': createdAt,
    };
  }
}
