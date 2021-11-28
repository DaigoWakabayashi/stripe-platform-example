import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  int currentIndex = 0;

  void onTabTapped(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
