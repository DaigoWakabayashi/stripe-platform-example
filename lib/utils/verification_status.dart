import 'package:flutter/foundation.dart';

enum Status {
  approved,
  idInputted,
  verified,
  unknown,
}

extension StatusExtension on Status {
  static Status parseUserStatus(String value) {
    switch (value) {
      case 'approved':
        return Status.approved;
      case 'idInputted':
        return Status.idInputted;
      case 'verified':
        return Status.verified;
    }
    return Status.unknown;
  }

  String get toEnumString => describeEnum(this);
}
