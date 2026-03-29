import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../config/constants.dart';
import '../models/transaction.dart';
import '../services/mongodb_service.dart';

class TransactionProvider extends ChangeNotifier {
  final MongoDbService _db;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider(this._db);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> get incomeTransactions =>
      _transactions.where((t) => t.type == TransactionType.income).toList();

  List<Transaction> get expenseTransactions =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docs = await _db.find(
        AppConstants.transactionsCollection,
        sort: {'date': -1},
      );
      _transactions = docs.map((d) => Transaction.fromMap(d)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(Transaction transaction) async {
    try {
      final map = transaction.toMap();
      map['_id'] = ObjectId();
      await _db.insert(AppConstants.transactionsCollection, map);
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> update(Transaction transaction) async {
    if (transaction.id == null) return;
    try {
      await _db.replaceDoc(
        AppConstants.transactionsCollection,
        transaction.id!,
        transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      );
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(ObjectId id) async {
    try {
      await _db.delete(AppConstants.transactionsCollection, id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // -- Filters --

  List<Transaction> filterByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<Transaction> filterByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> filterByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  List<Transaction> currentMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return filterByDateRange(start, end);
  }

  double monthlyIncome() {
    return currentMonthTransactions()
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double monthlyExpense() {
    return currentMonthTransactions()
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
