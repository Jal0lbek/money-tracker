class DebtModel {
  final int? id;
  final String type; // qarzdor (menga qarzi bor), qarz (mendan oldi)
  final String personName;
  final double amount;
  final double paidAmount;
  final String? note;
  final String date;
  final String? dueDate;
  final bool isPaid;

  DebtModel({
    this.id,
    required this.type,
    required this.personName,
    required this.amount,
    this.paidAmount = 0,
    this.note,
    required this.date,
    this.dueDate,
    this.isPaid = false,
  });

  double get remainingAmount => amount - paidAmount;

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      personName: map['person_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num? ?? 0).toDouble(),
      note: map['note'] as String?,
      date: map['date'] as String,
      dueDate: map['due_date'] as String?,
      isPaid: (map['is_paid'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'person_name': personName,
      'amount': amount,
      'paid_amount': paidAmount,
      'note': note,
      'date': date,
      'due_date': dueDate,
      'is_paid': isPaid ? 1 : 0,
    };
  }
}
