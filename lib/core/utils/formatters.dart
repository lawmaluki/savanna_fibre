import 'package:intl/intl.dart';

final _whole = NumberFormat('#,##0', 'en_US');
final _cents = NumberFormat('#,##0.00', 'en_US');

/// `KES 2,500` or, with [cents], `KES 2,500.00`.
String kes(num value, {bool cents = false}) => 'KES ${cents ? _cents.format(value) : _whole.format(value)}';

String fmtDate(DateTime d) => DateFormat('d MMM yyyy').format(d);
String fmtDateShort(DateTime d) => DateFormat('d MMM').format(d);
String fmtDateTime(DateTime d) => DateFormat('d MMM yyyy, h:mm a').format(d);

/// `+254734222990` → `+254 734 222 990`.
String fmtPhone(String e164) {
  final digits = e164.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('254')) {
    return '+254 ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
  }
  return e164;
}

/// Normalises a Kenyan mobile number typed as 07…, 7…, 254… or +254… to
/// `+2547XXXXXXXX`. Returns null when it isn't a valid mobile number.
String? normaliseKePhone(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('254')) d = d.substring(3);
  if (d.startsWith('0')) d = d.substring(1);
  if (d.length != 9 || !(d.startsWith('7') || d.startsWith('1'))) return null;
  return '+254$d';
}

String greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
