import 'package:stripe_platform_example/utils/verification_status.dart';

class User {
  String? id;
  String? displayName;
  String? email;
  String? customerId;
  String? accountId;
  String? sourceId;
  VerificationStatus? verificationStatus;

  User({
    this.id,
    this.displayName,
    this.email,
    this.customerId,
    this.accountId,
    this.sourceId,
    this.verificationStatus,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    customerId = json['customerId'];
    accountId = json['accountId'];
    sourceId = json['sourceId'];
    verificationStatus =
        StatusExtension.parseUserStatus(json['verificationStatus'] as String);
  }
}
