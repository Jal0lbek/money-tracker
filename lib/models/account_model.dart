class AccountModel {
  final int? id;
  final String name;
  double balance;
  final String type;
  final String currency;
  final String? icon;
  final String? color;

  AccountModel({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.currency = 'UZS',
    this.icon,
    this.color,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      type: map['type'] as String,
      currency: map['currency'] as String? ?? 'UZS',
      icon: map['icon'] as String?,
      color: map['color'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'balance': balance,
      'type': type,
      'currency': currency,
      'icon': icon,
      'color': color,
    };
  }

  AccountModel copyWith({
    int? id,
    String? name,
    double? balance,
    String? type,
    String? currency,
    String? icon,
    String? color,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
