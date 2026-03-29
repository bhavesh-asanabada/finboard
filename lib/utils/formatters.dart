import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy  h:mm a');
  static final _timeFormat = DateFormat('h:mm a');
  static final _monthYearFormat = DateFormat('MMMM yyyy');

  static String currency(double amount, {String symbol = '\$'}) {
    if (symbol != '\$') {
      return NumberFormat.currency(symbol: symbol).format(amount);
    }
    return _currencyFormat.format(amount);
  }

  static String date(DateTime date) => _dateFormat.format(date);

  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt);

  static String time(DateTime dt) => _timeFormat.format(dt);

  static String monthYear(DateTime dt) => _monthYearFormat.format(dt);

  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  static String durationFromMinutes(int minutes) {
    return duration(Duration(minutes: minutes));
  }
}
