import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class CustomizerNotifier extends ChangeNotifier {
  CustomizerNotifier(PizzaType initial)
    : _leftType = initial,
      _rightType = initial;

  PizzaType _leftType;
  PizzaType _rightType;
  HalfSide _selectedSide = HalfSide.left;

  PizzaType get leftType => _leftType;
  PizzaType get rightType => _rightType;
  HalfSide get selectedSide => _selectedSide;

  double get price => _leftType.halfPrice + _rightType.halfPrice;

  CartPizza get cartPizza => CartPizza(
    leftHalf: PizzaHalf(type: _leftType, side: HalfSide.left),
    rightHalf: PizzaHalf(type: _rightType, side: HalfSide.right),
  );

  void selectSide(HalfSide side) {
    _selectedSide = side;
    notifyListeners();
  }

  void applyType(PizzaType type) {
    if (_selectedSide == HalfSide.left) {
      _leftType = type;
      _selectedSide = HalfSide.right;
    } else {
      _rightType = type;
      _selectedSide = HalfSide.left;
    }
    notifyListeners();
  }
}
