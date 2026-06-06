import 'package:flutter/material.dart';

class AmountVisibilityController {
  AmountVisibilityController._();

  static final ValueNotifier<bool> showAmounts = ValueNotifier<bool>(true);

  static bool get isVisible => showAmounts.value;

  static void setVisible(bool value) {
    showAmounts.value = value;
  }

  static String mask(String visibleText) {
    final blockCount = visibleText.replaceAll(RegExp(r'\s+'), '').length;
    return List.filled(blockCount <= 0 ? 1 : blockCount, '█').join();
  }
}
