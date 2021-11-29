import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_platform_example/domain/stripe_individual.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';
import 'package:stripe_platform_example/utils/validation_utils.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class IdentificationModel extends ChangeNotifier {
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  final String termText =
      '''Stripe Connectアカウント契約( https://stripe.com/jp/connect-account/legal )（Stripe利用規約( https://stripe.com/jp/legal )を含み、総称して「Stripeサービス契約」といいます。）''';
  final imageNoteText = '''
ご利用いただける本人確認画像は以下となります
- 運転免許証
- パスポート
- 外国国籍を持つ方の場合は在留カード
- 写真付きの住基カード
- マイナンバーカード（顔写真入り）

画像について
- ファイルサイズ5MB以内
- 8000px以下
- .pngもしくは.jpgの形式
本人確認およびクレジットカード決済については、Stripeを利用しています。

Stripeは業界においてPCIレベル1に準拠した最高水準のセキュリティを誇り、ご提供いただいたユーザーの全ての情報についても、安全が確保された状態で保管を行っております。
・Stripeにおけるセキュリティについて→ https://stripe.com/docs/security/stripe
・Stripeのプライバシーポリシーについて→ https://stripe.com/jp/privacy
''';

  final _userRepo = UserRepository();
  final _teacherRepo = UserRepository();

  bool isAcceptTerm = false;
  StripeIndividual? individual;
  List<String> requirements = [];
  TosAcceptance? tosAcceptance;
  PlatformFile? identificationImageFront;
  PlatformFile? identificationImageBack;
  String? dobText; // そのまま送らない生年月日、validation用

  User? user;

  /// 本人情報を取得
  Future fetchIndividual() async {
    try {
      user = await _fetchUser();
      // todo : StripeRepo に移管
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'asia-northeast1',
      ).httpsCallable('stripe-retrieveConnectAccount');
      final result = await callable.call({
        'accountId': user?.accountId,
      });
      final data = result.data;
      final json = Map<String, dynamic>.from(data['individual']);
      individual = StripeIndividual.fromJson(json);
    } catch (e) {
      print(e);
      // 新しいの入れる
      individual = StripeIndividual();
    } finally {
      endLoading();
    }
  }

  /// Stripe に本人確認情報を送信する
  Future updateIndividual() async {
    startLoading();

    // todo : バリデーションかける

    try {
      user = await _fetchUser();
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'asia-northeast1',
      ).httpsCallable('stripe-updateConnectAccount');
      final _ = await callable.call({
        'accountId': user?.accountId,
        'individual': individual?.toJson(),
        'tos_acceptance': tosAcceptance?.toJson(),
      });
    } catch (e) {
      print(e);
    } finally {
      endLoading();
    }
  }

  /// 生年月日
  void setDob(String dobText) {
    this.dobText = dobText;

    if (ValidationUtils.validateDob(dobText) != '') {
      return;
    }

    final List<String> dobArray = dobText.split('/');
    final newDob = Dob();
    newDob.year = int.parse(dobArray[0]);
    newDob.month = int.parse(dobArray[1]);
    newDob.day = int.parse(dobArray[2]);
    individual?.dob = newDob;
  }

  /// 利用規約
  void setTosAcceptance(bool value) async {
    isAcceptTerm = value;
    notifyListeners();

    if (isAcceptTerm) {
      // 利用規約
      final int date = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      final ip = await _getIP();
      tosAcceptance = TosAcceptance();
      tosAcceptance?.date = date;
      tosAcceptance?.ip = ip;
    }
  }

  /// 身分証明書のアップロード
  Future uploadIdImages() async {
    startLoading();

    try {
      // 本人確認画像
      final imageIdFront = await _uploadPhoto(identificationImageFront!);
      final imageIdBack = await _uploadPhoto(identificationImageBack!);

      final document = StripeDocument(imageIdFront, imageIdBack);
      final verification = StripeVerification(document);
      individual?.verification = verification;

      final user = await _fetchUser();
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'asia-northeast1',
      ).httpsCallable('stripe-updateStripeConnectAccount');
      final _ = await callable.call({
        'accountId': user?.accountId,
        'individual': individual?.toJson(),
        'tos_acceptance': tosAcceptance?.toJson(),
      });

      // 1秒に一回、statusをチェック（最大10回ループする）
      // 現在のstatusから変更があった場合にループを止める
      final maxRetry = 10;
      int retryCount = 0;
      while (retryCount < maxRetry) {
        // statusを取得
        final status = await _teacherRepo.fetchStatus(user?.id ?? '');
        // 現在のステータスから変更があった場合
        if (status != user?.status) {
          // スナックバー出す
          // showSnackBar(context, '身分証明書の提出が完了しました');
          // 新しいstatusを取得
          await fetchIndividual();
          break;
        }
        // 1秒待つ
        await Future.delayed(Duration(seconds: 1));
        retryCount++;
      }
    } catch (e) {
      print(e);
    } finally {
      endLoading();
    }
  }

  /// 利用規約への同意
  Future uploadTosAcceptance() async {
    startLoading();
    try {
      final user = await _fetchUser();
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'asia-northeast1',
      ).httpsCallable('stripe-updateTosAcceptance');
      final _ = await callable.call({
        'accountId': user?.accountId,
        'tos_acceptance': tosAcceptance?.toJson(),
      });
    } catch (e) {
      print(e);
    } finally {
      endLoading();
    }
  }

  /// user ドキュメントを返す
  Future<User?> _fetchUser() async {
    final user = await _userRepo.fetch();
    return user;
  }

  /// IPアドレスを返す
  Future<String> _getIP() async {
    try {
      final url = Uri.parse('https://api.ipify.org');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  /// 身分証明画像をピックする（オモテ）
  void showIdentificationImageFrontPicker() {
    _selectImage(onSelected: (file) {
      identificationImageFront = file;
      notifyListeners();
    });
  }

  /// 身分証明画像をピックする（ウラ）
  void showIdentificationImageBackPicker() {
    _selectImage(onSelected: (file) {
      identificationImageBack = file;
      notifyListeners();
    });
  }

  /// ローカルのファイル選択
  void _selectImage({required Function(PlatformFile file) onSelected}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result == null) {
      return;
    }
    PlatformFile file = result.files.first;
    onSelected(file);
  }

  /// Stripe に画像をアップロードする
  Future<String> _uploadPhoto(PlatformFile file) async {
    final method = 'POST';
    final key = dotenv.env['STRIPE_PK'] as String;
    final uri = Uri.parse('https://files.stripe.com/v1/files');

    final headers = <String, String>{};
    headers['Accept-Charset'] = StripeApiHandler.CHARSET;
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['User-Agent'] = 'StripeSDK/v2';
    headers['Authorization'] = 'Bearer ${key}';

    final request = http.MultipartRequest(method, uri);
    request.headers.addAll(headers);

    final imageValue = http.MultipartFile.fromBytes(
      'file',
      file.bytes!.toList(),
      filename: file.name,
      // contentType: MediaType('application', 'octet-stream'),
    );
    request.files.add(imageValue);

    request.fields.addAll({
      'purpose': 'identity_document',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final status = response.statusCode;
    final body = response.body;
    final json = jsonDecode(body) as Map;

    if (status == 200) {
      final String id = json['id'];
      return id;
    } else {
      final errorMessage = json['error']['message'];
      throw (errorMessage);
    }
  }
}
