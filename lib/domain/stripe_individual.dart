/// 本人確認情報
class StripeIndividual {
  String? firstNameKanji;
  String? firstNameKana;
  String? lastNameKanji;
  String? lastNameKana;
  Dob? dob;
  Gender? gender = Gender.none;
  String? phoneNumber;
  Address? addressKanji = Address();
  Address? addressKana = Address();
  StripeVerification? verification;

  StripeIndividual();

  StripeIndividual.fromJson(Map<String, dynamic> json) {
    firstNameKanji = json['first_name_kanji'];
    firstNameKana = json['first_name_kana'];
    lastNameKanji = json['last_name_kanji'];
    lastNameKana = json['last_name_kana'];
    dob = Dob.fromJson(Map<String, dynamic>.from(json['dob']));
    phoneNumber = json['phone'].replaceFirst('+81', '0');
    gender = (json['gender'] as String).toEnumGender();
    addressKanji =
        Address.fromJson(Map<String, dynamic>.from(json['address_kanji']));
    addressKana =
        Address.fromJson(Map<String, dynamic>.from(json['address_kana']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name_kanji'] = firstNameKanji;
    data['first_name_kana'] = firstNameKana;
    data['last_name_kanji'] = lastNameKanji;
    data['last_name_kana'] = lastNameKana;

    if (dob != null) {
      data['dob'] = dob?.toJson();
    }
    data['phone'] = phoneNumber?.replaceFirst('0', '+81');

    if (gender != null) {
      data['gender'] = gender?.label;
    }

    if (addressKanji != null) {
      data['address_kanji'] = addressKanji?.toJson();
    }

    if (addressKana != null) {
      data['address_kana'] = addressKana?.toJson();
    }

    if (verification != null) {
      data['verification'] = verification?.toJson();
    }
    return data;
  }
}

/// 生年月日
class Dob {
  int? day;
  int? month;
  int? year;

  Dob();

  Dob.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['month'] = month;
    data['year'] = year;
    return data;
  }
}

/// 住所
class Address {
  String? postalCode;
  String? state; // 都道府県
  String? city; // 市区町村
  String? town; // 丁目まで
  String? line1; // 番地、号
  String? line2; // 建物・部屋番号

  Address();
  Address.fromJson(Map<String, dynamic> json) {
    postalCode = json['postal_code'];
    state = json['state'];
    city = json['city'];
    town = json['town'];
    line1 = json['line1'];
    line2 = json['line2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postal_code'] = postalCode;
    data['state'] = state;
    data['city'] = city;
    data['town'] = town;
    data['line1'] = line1;
    data['line2'] = line2;
    return data;
  }

  bool checkIfAnyIsNull() {
    return [
      state,
      city,
      town,
      line1,
    ].contains(null);
  }
}

/// Stripe利用規約への同意
class TosAcceptance {
  int? date;
  String? ip;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['ip'] = ip;
    return data;
  }
}

/// 性別
enum Gender {
  none,
  male,
  female,
}

extension on Gender {
  String get label => toString().split(".").last;
}

extension on String {
  Gender toEnumGender() {
    return Gender.values
        .firstWhere((e) => e.label == this, orElse: () => Gender.none);
  }
}

/// 本人書類
class StripeVerification {
  StripeDocument? document;

  StripeVerification(this.document);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['document'] = document?.toJson();
    return data;
  }
}

/// 本人確認書類（オモテ・ウラ）
class StripeDocument {
  String? front;
  String? back;

  StripeDocument(this.front, this.back);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['front'] = front;
    data['back'] = back;
    return data;
  }
}
