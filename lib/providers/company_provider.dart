import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../config/constants.dart';
import '../models/company.dart';
import '../services/mongodb_service.dart';

class CompanyProvider extends ChangeNotifier {
  final MongoDbService _db;

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  CompanyProvider(this._db);

  List<Company> get companies => _companies;
  List<Company> get activeCompanies =>
      _companies.where((c) => c.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docs = await _db.find(
        AppConstants.companiesCollection,
        sort: {'name': 1},
      );
      _companies = docs.map((d) => Company.fromMap(d)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(Company company) async {
    try {
      final map = company.toMap();
      map['_id'] = ObjectId();
      await _db.insert(AppConstants.companiesCollection, map);
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> update(Company company) async {
    if (company.id == null) return;
    try {
      await _db.replaceDoc(
        AppConstants.companiesCollection,
        company.id!,
        company.copyWith(updatedAt: DateTime.now()).toMap(),
      );
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleActive(Company company) async {
    await update(company.copyWith(isActive: !company.isActive));
  }

  Future<void> delete(ObjectId id) async {
    try {
      await _db.delete(AppConstants.companiesCollection, id);
      _companies.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Company? findById(ObjectId id) {
    try {
      return _companies.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
