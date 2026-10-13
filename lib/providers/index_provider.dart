import 'package:flutter/material.dart';

class IndexProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  set index(int newIndex) {
    if (_index == newIndex) return;
    _index = newIndex;
    notifyListeners();
  }

  void reset() {
    _index = 0;
    notifyListeners();
  }
}
