import 'package:flutter/foundation.dart';

enum VerificationStatus {
  unverified,
  pending,
  verified,
  unknown,
}

extension StatusExtension on VerificationStatus {
  static VerificationStatus parseUserStatus(String value) {
    switch (value) {
      case 'unverified':
        return VerificationStatus.unverified;
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
    }
    return VerificationStatus.unknown;
  }

  String get toEnumString => describeEnum(this);
}
