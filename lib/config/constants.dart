class AppConstants {
  AppConstants._();

  // MongoDB collection names
  static const String companiesCollection = 'companies';
  static const String timeEntriesCollection = 'time_entries';
  static const String transactionsCollection = 'transactions';

  // Default database name
  static const String defaultDatabase = 'finboard';
  static const String defaultPort = '27017';
  static const String defaultCurrency = 'USD';

  // Default expense categories
  static const List<String> defaultCategories = [
    'Food',
    'Travel',
    'Rent',
    'Utilities',
    'Entertainment',
    'Healthcare',
    'Shopping',
    'Education',
    'Salary',
    'Freelance',
    'Other',
  ];

  // Secure storage keys
  static const String keyDbHost = 'db_host';
  static const String keyDbPort = 'db_port';
  static const String keyDbName = 'db_name';
  static const String keyDbUsername = 'db_username';
  static const String keyDbPassword = 'db_password';
  static const String keyDbAdvancedMode = 'db_advanced_mode';
  static const String keyDbRawUri = 'db_raw_uri';
  static const String keyCustomCategories = 'custom_categories';
}
