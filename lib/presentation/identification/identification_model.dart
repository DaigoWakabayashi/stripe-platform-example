import 'package:flutter/cupertino.dart';

class IdentificationModel extends ChangeNotifier {
  bool isLoading = false;

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
