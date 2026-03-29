class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Amount']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    final number = double.tryParse(value);
    if (number == null) return 'Enter a valid number';
    if (number <= 0) return '$field must be greater than 0';
    return null;
  }

  static String? port(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final number = int.tryParse(value);
    if (number == null || number < 1 || number > 65535) {
      return 'Enter a valid port (1-65535)';
    }
    return null;
  }

  static String? mongoUri(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Connection URI is required';
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('mongodb://') &&
        !trimmed.startsWith('mongodb+srv://')) {
      return 'URI must start with mongodb:// or mongodb+srv://';
    }
    return null;
  }
}
