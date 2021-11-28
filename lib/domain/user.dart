import 'package:stripe_platform_example/utils/verification_status.dart';

class User {
  String? id;
  String? displayName;
  String? email;
  String? customerId;
  String? accountId;
  VerificationStatus? verificationStatus;

  User({
    this.id,
    this.displayName,
    this.email,
    this.customerId,
    this.accountId,
    this.verificationStatus,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    customerId = json['customerId'];
    accountId = json['accountId'];
    verificationStatus =
        StatusExtension.parseUserStatus(json['verificationStatus'] as String);
  }
}
