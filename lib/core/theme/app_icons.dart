import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:spendly/core/constants/app_enums.dart';

class AppIcons {
  const AppIcons._();

  static const search = LucideIcons.search;
  static const settings = LucideIcons.settings;
  static const bell = LucideIcons.bell;
  static const filter = LucideIcons.slidersHorizontal;
  static const calendar = LucideIcons.calendar;
  static const chevronRight = LucideIcons.chevronRight;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const user = LucideIcons.userRound;
  static const shield = LucideIcons.shield;
  static const notifications = LucideIcons.bell;
  static const categories = LucideIcons.grid2x2;
  static const repeat = LucideIcons.repeat;
  static const download = LucideIcons.download;
  static const upload = LucideIcons.upload;
  static const trash = LucideIcons.trash2;
  static const edit = LucideIcons.pencil;
  static const receipt = LucideIcons.receipt;
  static const car = LucideIcons.car;
  static const food = LucideIcons.utensils;
  static const bag = LucideIcons.shoppingBag;
  static const gym = LucideIcons.dumbbell;
  static const flight = LucideIcons.plane;
  static const money = LucideIcons.handCoins;
  static const personAdd = LucideIcons.userPlus;
  static const close = LucideIcons.x;
  static const plus = LucideIcons.plus;
  static const home = LucideIcons.house;
  static const history = LucideIcons.history;
  static const analytics = LucideIcons.chartLine;
  static const budget = LucideIcons.wallet;
  static const goals = LucideIcons.target;
  static const health = LucideIcons.heartPulse;
  static const eye = LucideIcons.eye;
  static const eyeOff = LucideIcons.eyeOff;

  static IconData getIconForCategory(
    String categoryName, [
    TransactionType? type,
  ]) {
    final name = categoryName.toLowerCase();
    if (name.contains('food') ||
        name.contains('dining') ||
        name.contains('restaurant')) {
      return AppIcons.food;
    }
    if (name.contains('transport') ||
        name.contains('uber') ||
        name.contains('taxi') ||
        name.contains('car') ||
        name.contains('bus')) {
      return AppIcons.car;
    }
    if (name.contains('shopping') ||
        name.contains('shop') ||
        name.contains('store') ||
        name.contains('bag') ||
        name.contains('grocery')) {
      return AppIcons.bag;
    }
    if (name.contains('bill') ||
        name.contains('utility') ||
        name.contains('electric') ||
        name.contains('receipt') ||
        name.contains('util')) {
      return AppIcons.receipt;
    }
    if (name.contains('health') ||
        name.contains('medical') ||
        name.contains('hospital')) {
      return AppIcons.health;
    }
    if (name.contains('gym') ||
        name.contains('workout') ||
        name.contains('fitness') ||
        name.contains('dumbbell')) {
      return AppIcons.gym;
    }
    if (name.contains('travel') ||
        name.contains('flight') ||
        name.contains('air') ||
        name.contains('trip')) {
      return AppIcons.flight;
    }
    if (name.contains('salary') ||
        name.contains('income') ||
        name.contains('transfer') ||
        name.contains('freelance') ||
        name.contains('business') ||
        name.contains('work')) {
      return AppIcons.money;
    }
    if (name.contains('rent') ||
        name.contains('home') ||
        name.contains('house')) {
      return AppIcons.home;
    }

    // Fallbacks
    if (type == TransactionType.income) {
      return LucideIcons.arrowDownLeft;
    } else if (type == TransactionType.expense) {
      return LucideIcons.arrowUpRight;
    }
    return AppIcons.receipt;
  }
}
