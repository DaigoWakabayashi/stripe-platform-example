import 'package:intl/intl.dart';

extension IntExtension on int? {
  String toSplitCommaString() {
    final formatter = NumberFormat("#,###");
    return formatter.format(this);
  }
}
