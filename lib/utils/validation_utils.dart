class ValidationUtils {
  static String validatePassword(String pass) {
    if (pass.isNotEmpty && pass.length < 4) {
      return 'パスワードは4文字以上でお願いします';
    }

    if (pass.isNotEmpty && pass.length > 72) {
      return 'パスワードは72文字以下でお願いします';
    }
    return '';
  }

  static String validateKatakana(String word) {
    if (!RegExp(r'^[ァ-ンヴー\s]+$').hasMatch(word)) {
      return 'カタカナの形式が間違っています';
    }
    return '';
  }

  static String validateKatakanaAdress(String word) {
    if (!RegExp(r'^([0-9０-９]|[ァ-ンヴー-\s])+$').hasMatch(word)) {
      return 'カタカナと数字で入力してください';
    }
    return '';
  }

  static String validateRomeWord(String word) {
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(word)) {
      return 'ローマ字の形式が間違っています';
    }
    return '';
  }

  static String validateEmail(String email) {
    final emailRe = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    if (!emailRe.hasMatch(email)) {
      return 'メールアドレスの形式が違います';
    }
    return '';
  }

  static String validateDob(String dob) {
    final re = RegExp(
      r'^[0-9]{4}/(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])$',
    );
    if (!re.hasMatch(dob)) {
      return '生年月日の形式が違います';
    }
    return '';
  }

  static String validatePhoneNumber(String phone) {
    String phoneStringNew = phone.replaceAll('-', '');
    if (phoneStringNew.length != 10 && phoneStringNew.length != 11) {
      return '電話番号は10桁か11桁の数字でお願い致します';
    }
    return '';
  }

  static String validateZipcode(String zipcode) {
    if (zipcode.length != 8) {
      return '郵便番号はハイフン区切りの7桁の数字でお願い致します';
    }
    return '';
  }
}
