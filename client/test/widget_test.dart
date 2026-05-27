// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:pizzaf/features/customizer/customizer_notifier.dart';
import 'package:shared/shared.dart';

void main() {
  test('customizer builds a cart pizza from selected halves', () {
    final notifier = CustomizerNotifier(PizzaType.pepperoni);

    notifier.applyType(PizzaType.margherita);
    notifier.applyType(PizzaType.hawaiian);

    final pizza = notifier.cartPizza;
    expect(pizza.leftHalf.type, PizzaType.margherita);
    expect(pizza.rightHalf.type, PizzaType.hawaiian);
    expect(pizza.price, 10.48);
  });
}
