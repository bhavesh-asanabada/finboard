import 'package:mongo_dart/mongo_dart.dart';

enum ConnectionState { disconnected, connecting, connected, error }

class MongoDbService {
  static final MongoDbService _instance = MongoDbService._internal();
  factory MongoDbService() => _instance;
  MongoDbService._internal();

  Db? _db;
  ConnectionState _state = ConnectionState.disconnected;
  String? _lastError;

  ConnectionState get state => _state;
  String? get lastError => _lastError;
  bool get isConnected => _state == ConnectionState.connected;

  /// Connect to MongoDB using the given URI.
  Future<bool> connect(String uri) async {
    if (_state == ConnectionState.connecting) return false;

    _state = ConnectionState.connecting;
    _lastError = null;

    try {
      // Close existing connection if any
      await _disconnect();

      _db = Db(uri);
      await _db!.open();

      if (_db!.isConnected) {
        _state = ConnectionState.connected;
        return true;
      } else {
        _state = ConnectionState.error;
        _lastError = 'Failed to establish connection';
        return false;
      }
    } catch (e) {
      _state = ConnectionState.error;
      _lastError = e.toString();
      _db = null;
      return false;
    }
  }

  /// Test a connection URI without persisting it.
  Future<(bool success, String? error)> testConnection(String uri) async {
    Db? testDb;
    try {
      testDb = Db(uri);
      await testDb.open();
      final connected = testDb.isConnected;
      await testDb.close();
      return (connected, connected ? null : 'Could not connect');
    } catch (e) {
      try {
        await testDb?.close();
      } catch (_) {}
      return (false, e.toString());
    }
  }

  /// Get a collection reference.
  DbCollection collection(String name) {
    _ensureConnected();
    return _db!.collection(name);
  }

  // --- Generic CRUD ---

  Future<ObjectId> insert(String collectionName, Map<String, dynamic> doc) async {
    _ensureConnected();
    final result = await _db!.collection(collectionName).insertOne(doc);
    return result.document?['_id'] as ObjectId? ?? ObjectId();
  }

  Future<List<Map<String, dynamic>>> find(
    String collectionName, {
    Map<String, dynamic>? filter,
    Map<String, dynamic>? sort,
    int? limit,
  }) async {
    _ensureConnected();
    SelectorBuilder selector = SelectorBuilder();
    if (filter != null) {
      selector.raw(filter);
    }
    if (sort != null) {
      sort.forEach((key, value) {
        selector.sortBy(key, descending: value == -1);
      });
    }
    if (limit != null) {
      selector.limit(limit);
    }
    final results = await _db!.collection(collectionName).find(selector).toList();
    return results;
  }

  Future<Map<String, dynamic>?> findOne(
    String collectionName, {
    Map<String, dynamic>? filter,
  }) async {
    _ensureConnected();
    return _db!.collection(collectionName).findOne(filter);
  }

  Future<void> update(
    String collectionName,
    ObjectId id,
    Map<String, dynamic> fields,
  ) async {
    _ensureConnected();
    var builder = ModifierBuilder();
    fields.forEach((key, value) {
      builder.set(key, value);
    });
    builder.set('updatedAt', DateTime.now().toUtc());
    await _db!.collection(collectionName).updateOne(
          where.id(id),
          builder,
        );
  }

  Future<void> replaceDoc(
    String collectionName,
    ObjectId id,
    Map<String, dynamic> doc,
  ) async {
    _ensureConnected();
    await _db!.collection(collectionName).replaceOne(
          where.id(id),
          doc,
        );
  }

  Future<void> delete(String collectionName, ObjectId id) async {
    _ensureConnected();
    await _db!.collection(collectionName).deleteOne(where.id(id));
  }

  Future<void> disconnect() async {
    await _disconnect();
    _state = ConnectionState.disconnected;
    _lastError = null;
  }

  // --- Private ---

  Future<void> _disconnect() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }
    } catch (_) {}
    _db = null;
  }

  void _ensureConnected() {
    if (_db == null || !_db!.isConnected) {
      throw StateError('Not connected to MongoDB. Call connect() first.');
    }
  }
}
