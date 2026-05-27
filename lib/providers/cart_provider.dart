import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _cart = {};

  Map<String, int> get cart => _cart;

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);

  void add(String id) {
    _cart[id] = (_cart[id] ?? 0) + 1;
    notifyListeners(); // ⬅️ دي اللي بتخلي الشاشات تحدث نفسها
  }

  void remove(String id) {
    if ((_cart[id] ?? 0) > 1) {
      _cart[id] = _cart[id]! - 1;
    } else {
      _cart.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }
}
