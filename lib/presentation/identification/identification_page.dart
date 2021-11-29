import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'identification_model.dart';

class IdentificationPage extends StatelessWidget {
  const IdentificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IdentificationModel>(
      create: (_) => IdentificationModel(),
      child: Consumer<IdentificationModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('本人確認')),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('本人確認ページ'),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
