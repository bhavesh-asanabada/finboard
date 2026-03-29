import 'package:mongo_dart/mongo_dart.dart';

enum PayType { hourly, monthly }

class Company {
  final ObjectId? id;
  final String name;
  final PayType payType;
  final double payRate;
  final String currency;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    this.id,
    required this.name,
    required this.payType,
    required this.payRate,
    this.currency = 'USD',
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'payType': payType.name,
      'payRate': payRate,
      'currency': currency,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toUtc(),
      'updatedAt': updatedAt.toUtc(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['_id'] as ObjectId?,
      name: map['name'] as String? ?? '',
      payType: PayType.values.firstWhere(
        (e) => e.name == map['payType'],
        orElse: () => PayType.hourly,
      ),
      payRate: (map['payRate'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      notes: map['notes'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.now(),
    );
  }

  Company copyWith({
    ObjectId? id,
    String? name,
    PayType? payType,
    double? payRate,
    String? currency,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      payType: payType ?? this.payType,
      payRate: payRate ?? this.payRate,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
