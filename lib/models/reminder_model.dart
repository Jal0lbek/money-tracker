class ReminderModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // kirim, chiqim
  final int dayOfMonth;
  final bool isRecurring;
  final bool isActive;
  final String? note;
  final String createdAt;

  ReminderModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.dayOfMonth,
    this.isRecurring = true,
    this.isActive = true,
    this.note,
    required this.createdAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      dayOfMonth: map['day_of_month'] as int,
      isRecurring: (map['is_recurring'] as int? ?? 1) == 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'day_of_month': dayOfMonth,
      'is_recurring': isRecurring ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'note': note,
      'created_at': createdAt,
    };
  }
}
