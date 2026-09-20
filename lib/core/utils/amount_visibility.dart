import 'package:flutter/material.dart';

class AmountVisibilityController {
  AmountVisibilityController._();

  static final ValueNotifier<bool> showAmounts = ValueNotifier<bool>(true);

  static bool get isVisible => showAmounts.value;

  static void setVisible(bool value) {
    showAmounts.value = value;
  }
}
