class TransactionModel {
  final int? id;
  final String type;
  final double amount;
  final int? accountFrom;
  final int? accountTo;
  final int? categoryId;
  final String? note;
  final String date;
  final String createdAt;
  final String? receiptPath;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    this.accountFrom,
    this.accountTo,
    this.categoryId,
    this.note,
    required this.date,
    required this.createdAt,
    this.receiptPath,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      accountFrom: map['account_from'] as int?,
      accountTo: map['account_to'] as int?,
      categoryId: map['category_id'] as int?,
      note: map['note'] as String?,
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
      receiptPath: map['receipt_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'amount': amount,
      'account_from': accountFrom,
      'account_to': accountTo,
      'category_id': categoryId,
      'note': note,
      'date': date,
      'created_at': createdAt,
      'receipt_path': receiptPath,
    };
  }
}
