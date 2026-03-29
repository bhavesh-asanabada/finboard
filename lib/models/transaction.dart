import 'package:mongo_dart/mongo_dart.dart';

enum TransactionType { income, expense }

class Transaction {
  final ObjectId? id;
  final TransactionType type;
  final double amount;
  final String category;
  final String? description;
  final ObjectId? companyId;
  final String? companyName;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    this.companyId,
    this.companyName,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'type': type.name,
      'amount': amount,
      'category': category,
      'description': description,
      'companyId': companyId,
      'companyName': companyName,
      'date': date.toUtc(),
      'createdAt': createdAt.toUtc(),
      'updatedAt': updatedAt.toUtc(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['_id'] as ObjectId?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String?,
      companyId: map['companyId'] as ObjectId?,
      companyName: map['companyName'] as String?,
      date: map['date'] is DateTime
          ? map['date'] as DateTime
          : DateTime.now(),
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.now(),
    );
  }

  Transaction copyWith({
    ObjectId? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? description,
    ObjectId? companyId,
    String? companyName,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
