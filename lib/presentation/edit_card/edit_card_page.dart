import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/utils/show_dialog.dart';

import 'edit_card_model.dart';

class EditCardPage extends StatelessWidget {
  const EditCardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditCardModel>(
      create: (_) => EditCardModel()..fetch(),
      child: Consumer<EditCardModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('クレジットカード登録')),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GestureDetector(
                    onTap: () {
                      model.unFocusAll();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// カード情報
                        _cardInfoBody(context, model),

                        const Spacer(),

                        /// ボタン
                        model.isCardRegister
                            ?
                            // カード登録済
                            ElevatedButton(
                                child: const Text('新しいカードを登録する'),
                                onPressed: () {
                                  // ローカルのカード情報をクリアする
                                  model.clearCardCache();
                                },
                              )
                            :
                            // カード未登録
                            ElevatedButton(
                                child: const Text('保存'),
                                onPressed: model.isFilledAll
                                    ? () async {
                                        // 保存するしないに関わらず、一旦遷移時にカード情報を登録
                                        try {
                                          await model.saveCardInfo();
                                          await showTextDialog(
                                            context,
                                            'カード情報を保存しました',
                                          );
                                        } catch (e) {
                                          showTextDialog(context, e.toString());
                                        }
                                      }
                                    : null,
                              ),
                        const SizedBox(height: 80)
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// カード部分
  Widget _cardInfoBody(BuildContext context, EditCardModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// カード番号
        const Text(
          'クレジットカード番号',
        ),
        model.isCardRegister
            ? Text(
                model.creditCardNow.cardNumber,
              )
            : TextField(
                onChanged: (text) {
                  model.changeCreditNumber(text);
                },
                decoration: const InputDecoration(
                  hintText: '4242 4242 4242 4242',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CreditCardNumberInputFormatter()],
                focusNode: model.numberNode,
              ),

        /// 有効期限・CVC
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('有効期限'),
                  model.isCardRegister
                      ? Text(
                          model.creditCardNow.exp,
                        )
                      : TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            model.changeExp(text);
                          },
                          decoration: const InputDecoration(
                            hintText: '月 / 年',
                          ),
                          inputFormatters: [
                            CreditCardExpirationDateFormatter()
                          ],
                          focusNode: model.expNode,
                        ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            model.isCardRegister
                ? const Spacer()
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVC　', // 全角スペーズを入れないと有効期限とズレが生じる
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '123',
                          ),
                          onChanged: (text) {
                            model.changeCvc(text);
                          },
                          inputFormatters: [CreditCardCvcInputFormatter()],
                          focusNode: model.cvcNode,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
