import 'package:flutter/foundation.dart';

enum Status {
  unverified,
  idInputted,
  verified,
  unknown,
}

extension StatusExtension on Status {
  static Status parseUserStatus(String value) {
    switch (value) {
      case 'unverified':
        return Status.unverified;
      case 'idInputted':
        return Status.idInputted;
      case 'verified':
        return Status.verified;
    }
    return Status.unknown;
  }

  String get toEnumString => describeEnum(this);
}
