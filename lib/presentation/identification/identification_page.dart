import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/domain/stripe_individual.dart';
import 'package:stripe_platform_example/utils/show_dialog.dart';
import 'package:stripe_platform_example/utils/verification_status.dart';

import 'identification_model.dart';

class IdentificationPage extends StatelessWidget {
  const IdentificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IdentificationModel>(
      create: (_) => IdentificationModel()..fetchIndividual(),
      child: Consumer<IdentificationModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('本人確認')),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(child: _body(context, model)),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, IdentificationModel model) {
    if (model.individual == null || model.user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        _currentStepWidget(context, model),
      ],
    );
  }

  Widget _currentStepWidget(BuildContext context, IdentificationModel model) {
    final status = model.user?.status;

    switch (status) {
      case Status.unverified:
        return _unverifiedBody(context, model);
      case Status.verified:
        return _verifiedBody(context, model);
      default:
        return Container();
    }
  }

  /// 本人情報の入力画面
  Widget _unverifiedBody(BuildContext context, IdentificationModel model) {
    final individual = model.individual;

    return Column(
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: model.individual?.lastNameKanji,
                    onChanged: (text) {
                      model.individual?.lastNameKanji = text;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: '姓（漢字）',
                      hintText: "田中",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.familyName],
                  ),
                  TextFormField(
                    initialValue: model.individual?.firstNameKanji,
                    onChanged: (text) {
                      model.individual?.firstNameKanji = text;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: '名（漢字）',
                      hintText: "太郎",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.givenName],
                  ),
                  const Divider(),
                  TextFormField(
                    initialValue: model.individual?.lastNameKana,
                    onChanged: (text) {
                      model.individual?.lastNameKana = text;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      labelText: '姓（カタカナ）',
                      hintText: "タナカ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    initialValue: model.individual?.firstNameKana,
                    onChanged: (text) {
                      model.individual?.firstNameKana = text;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      labelText: '名（カタカナ）',
                      hintText: "タロウ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(),
                  TextFormField(
                    initialValue: model.individual?.dob != null
                        ? model.individual?.dob.toString()
                        : '',
                    onChanged: (text) {
                      model.setDob(text);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskedInputFormatter('####/##/##'),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      labelText: '生年月日',
                      hintText: "1991/07/15",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(),
                  DropdownButtonFormField<Gender>(
                    value: individual?.gender,
                    items: [
                      DropdownMenuItem(
                        value: Gender.none,
                        child: Text(
                          '選択してください',
                        ),
                      ),
                      DropdownMenuItem(
                        value: Gender.male,
                        child: Text(
                          '男性',
                        ),
                      ),
                      DropdownMenuItem(
                        value: Gender.female,
                        child: Text(
                          '女性',
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      model.individual?.gender = value ?? Gender.none;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people_alt),
                      labelText: '性別',
                      hintText: "選択してください",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Divider(),
                  TextFormField(
                    initialValue: model.individual?.phoneNumber,
                    onChanged: (text) {
                      model.individual?.phoneNumber = text;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: '電話番号',
                      hintText: "000-0000-0000",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.postalCode,
                    onChanged: (text) {
                      model.individual?.addressKanji?.postalCode = text;
                      model.individual?.addressKana?.postalCode = text;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MaskedInputFormatter('###-####'),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '郵便番号',
                      hintText: "150-0001",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.postalCode],
                  ),
                  const Divider(),
                  TextFormField(
                    initialValue: model.individual?.addressKanji?.state,
                    onChanged: (text) {
                      model.individual?.addressKanji?.state = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '都道府県',
                      hintText: "東京都",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.streetAddressLevel1],
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKanji?.city,
                    onChanged: (text) {
                      model.individual?.addressKanji?.city = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '市区町村',
                      hintText: "渋谷区",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.streetAddressLevel2],
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKanji?.town,
                    onChanged: (text) {
                      model.individual?.addressKanji?.town = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '丁目まで',
                      hintText: "神宮前６丁目",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.streetAddressLine1],
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKanji?.line1,
                    onChanged: (text) {
                      model.individual?.addressKanji?.line1 = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '番地、号',
                      hintText: "20-10",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.streetAddressLine2],
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKanji?.line2,
                    onChanged: (text) {
                      model.individual?.addressKanji?.line2 = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map),
                      labelText: '建物・部屋番号',
                      hintText: "KBOYビル102",
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.streetAddressLine3],
                  ),
                  const Divider(),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.state,
                    onChanged: (text) {
                      model.individual?.addressKana?.state = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: '都道府県（カタカナ）',
                      hintText: "トウキョウト",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.city,
                    onChanged: (text) {
                      model.individual?.addressKana?.city = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: '市区町村（カタカナ）',
                      hintText: "シブヤク",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.town,
                    onChanged: (text) {
                      model.individual?.addressKana?.town = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: '丁目まで（カタカナ）',
                      hintText: "ジングウマエ６チョウメ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.line1,
                    onChanged: (text) {
                      model.individual?.addressKana?.line1 = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: '番地、号（カタカナ）',
                      hintText: "20-10",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    initialValue: model.individual?.addressKana?.line2,
                    onChanged: (text) {
                      model.individual?.addressKana?.line2 = text;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: '建物・部屋番号（カタカナ）',
                      hintText: "KBOYビル102",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text(
                          '写真付き身分証明書 - 表',
                        ),
                        onPressed: () {
                          model.showIdentificationImageFrontPicker();
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      model.identificationImageFront != null
                          ? Icon(Icons.check_circle)
                          : Container(
                              width: 48,
                              height: 32,
                              color: Colors.black12,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text(
                          '写真付き身分証明書 - 裏',
                        ),
                        onPressed: () {
                          model.showIdentificationImageBackPicker();
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      model.identificationImageBack != null
                          ? Icon(Icons.check_circle)
                          : Container(
                              width: 48,
                              height: 32,
                              color: Colors.black12,
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                            )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    child: Text(
                      '身分証明書の画像についての注意事項',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      // 利用規約の表示
                      showTextDialog(context, model.imageNoteText);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: model.isAcceptTerm,
                        onChanged: (value) {
                          model.setTosAcceptance(value!);
                        },
                      ),
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            EdgeInsets.zero,
                          ),
                        ),
                        child: Text('利用規約'),
                        onPressed: () {
                          // 利用規約の表示
                          showTextDialog(context, model.termText);
                        },
                      ),
                      SelectableText(
                        'へ同意する',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Center(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              child: Text('アップロード'),
              onPressed: model.isAcceptTerm
                  ? () async {
                      try {
                        await model.updateIndividual();
                        await model.uploadIdImages();
                        await showTextDialog(context, '本人確認情報をアップロードしました');
                        Navigator.of(context).pop();
                      } catch (e) {
                        showTextDialog(context, e.toString());
                      }
                    }
                  : null,
            ),
          ),
        ),
        SizedBox(
          height: 64,
        ),
      ],
    );
  }

  /// 本人確認完了画面
  Widget _verifiedBody(BuildContext context, IdentificationModel model) {
    final individual = model.individual;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Stripeによる本人確認が完了しました\n以下の内容で本人確認済みです',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    individual?.lastNameKanji ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    individual?.firstNameKanji ?? '',
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    individual?.lastNameKana ?? '',
                  ),
                  SizedBox(width: 4),
                  Text(
                    individual?.firstNameKana ?? '',
                  ),
                ],
              ),
              const Divider(),
              Text(
                individual?.dob.toString() ?? '',
              ),
              const Divider(),
              Text(
                individual?.gender == Gender.male ? '男性' : '女性',
              ),
              const Divider(),
              Text(
                individual?.phoneNumber ?? '',
              ),
              const Divider(),
              Text(
                individual?.addressKanji?.postalCode ?? '',
              ),
              Text(
                individual?.addressKanji?.state ?? '',
              ),
              Text(
                individual?.addressKanji?.city ?? '',
              ),
              Text(
                individual?.addressKanji?.town ?? '',
              ),
              Text(
                individual?.addressKanji?.line1 ?? '',
              ),
              individual?.addressKanji?.line2 != null
                  ? Text(
                      individual!.addressKanji!.line2!,
                    )
                  : const SizedBox(),
              const Divider(),
              Text(
                individual?.addressKana?.state ?? '',
              ),
              Text(
                individual?.addressKana?.city ?? '',
              ),
              Text(
                individual?.addressKana?.town ?? '',
              ),
              Text(
                individual?.addressKana?.line1 ?? '',
              ),
              individual?.addressKana?.line2 != null
                  ? Text(
                      individual!.addressKana!.line2!,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
