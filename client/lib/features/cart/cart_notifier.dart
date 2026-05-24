import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class CartNotifier extends ChangeNotifier {
  final List<CartPizza> _items = [];

  List<CartPizza> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.price);

  void add(CartPizza pizza) {
    _items.add(pizza);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
