import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/account/account_page.dart';
import 'package:stripe_platform_example/presentation/product_list/product_list_page.dart';

import 'navigation_model.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationModel>(
      create: (_) => NavigationModel()..init(),
      child: Consumer<NavigationModel>(
        builder: (context, model, child) {
          final List<String> _tabNames = [
            "商品一覧",
            "マイページ",
          ];
          return Scaffold(
            body: _topPageBody(context),
            bottomNavigationBar: BottomNavigationBar(
              onTap: model.onTabTapped,
              currentIndex: model.currentIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: _tabNames[0],
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_rounded),
                  label: _tabNames[1],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topPageBody(BuildContext context) {
    final model = Provider.of<NavigationModel>(context);
    final currentIndex = model.currentIndex;
    return Stack(
      children: <Widget>[
        _tabPage(
          currentIndex,
          0,
          const ProductListPage(),
        ),
        _tabPage(
          currentIndex,
          1,
          const AccountPage(),
        ),
      ],
    );
  }

  Widget _tabPage(int currentIndex, int tabIndex, StatelessWidget page) {
    return Visibility(
      visible: currentIndex == tabIndex,
      maintainState: true,
      child: page,
    );
  }
}
