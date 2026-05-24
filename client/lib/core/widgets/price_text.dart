import 'package:flutter/material.dart';

class PriceText extends StatelessWidget {
  final double value;
  final TextStyle? style;

  const PriceText(this.value, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text('\$${value.toStringAsFixed(2)}', style: style);
  }
}
