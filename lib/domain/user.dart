import 'package:stripe_platform_example/utils/verification_status.dart';

class User {
  String? id;
  String? displayName;
  String? email;
  String? customerId;
  String? accountId;
  String? sourceId;
  Status? status;
  bool? chargesEnabled;

  User({
    this.id,
    this.displayName,
    this.email,
    this.customerId,
    this.accountId,
    this.sourceId,
    this.status,
    this.chargesEnabled,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    customerId = json['customerId'];
    accountId = json['accountId'];
    sourceId = json['sourceId'];
    status = StatusExtension.parseUserStatus(json['status'] as String);
    chargesEnabled = json['chargesEnabled'];
  }
}
