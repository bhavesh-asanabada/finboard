class DbCredentials {
  final String host;
  final String port;
  final String databaseName;
  final String username;
  final String password;
  final bool isAdvancedMode;
  final String rawUri;

  const DbCredentials({
    this.host = '',
    this.port = '27017',
    this.databaseName = 'finboard',
    this.username = '',
    this.password = '',
    this.isAdvancedMode = false,
    this.rawUri = '',
  });

  bool get isComplete {
    if (isAdvancedMode) {
      return rawUri.startsWith('mongodb://') ||
          rawUri.startsWith('mongodb+srv://');
    }
    return host.isNotEmpty &&
        databaseName.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty;
  }

  String buildUri() {
    if (isAdvancedMode) return rawUri;

    final encodedUser = Uri.encodeComponent(username);
    final encodedPass = Uri.encodeComponent(password);

    if (host.contains('.mongodb.net')) {
      // Atlas SRV connection
      return 'mongodb+srv://$encodedUser:$encodedPass@$host/$databaseName'
          '?retryWrites=true&w=majority';
    }

    // Standard connection
    final effectivePort = port.isEmpty ? '27017' : port;
    return 'mongodb://$encodedUser:$encodedPass@$host:$effectivePort/$databaseName'
        '?retryWrites=true&w=majority';
  }

  DbCredentials copyWith({
    String? host,
    String? port,
    String? databaseName,
    String? username,
    String? password,
    bool? isAdvancedMode,
    String? rawUri,
  }) {
    return DbCredentials(
      host: host ?? this.host,
      port: port ?? this.port,
      databaseName: databaseName ?? this.databaseName,
      username: username ?? this.username,
      password: password ?? this.password,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      rawUri: rawUri ?? this.rawUri,
    );
  }
}
