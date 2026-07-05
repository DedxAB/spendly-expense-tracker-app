import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

Color _iconDefault(Brightness b) =>
    b == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF333333);
Color _iconChevron(Brightness b) =>
    b == Brightness.dark ? const Color(0xFFE8E8E8) : const Color(0xFF222222);
Color _iconHistory(Brightness b) =>
    b == Brightness.dark ? const Color(0xFFD4D4D4) : const Color(0xFF444444);

Color _iconFor(Brightness b, Color light, Color dark) =>
    b == Brightness.light ? light : dark;

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
  static const usersRound = LucideIcons.usersRound;
  static const userRoundPlus = LucideIcons.userRoundPlus;
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
  static const arrowBack = LucideIcons.arrowLeft;

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
    } else if (type == TransactionType.investment) {
      return LucideIcons.trendingUp;
    }
    return AppIcons.receipt;
  }

  static Color getColorForCategory(
    String categoryName, [
    TransactionType? type,
    Brightness brightness = Brightness.dark,
  ]) {
    return getColorForIcon(
      getIconForCategory(categoryName, type),
      label: categoryName,
      type: type,
      brightness: brightness,
    );
  }

  static Color getColorForIcon(
    IconData icon, {
    String? label,
    TransactionType? type,
    Brightness brightness = Brightness.dark,
  }) {
    final name = label?.toLowerCase() ?? '';

    if (icon == AppIcons.bell || name.contains('notification')) {
      return _iconFor(brightness, const Color(0xFFD4A017), const Color(0xFFE8B830));
    }
    if (icon == AppIcons.shield) {
      return _iconFor(brightness, const Color(0xFF2D9F63), const Color(0xFF3DD07B));
    }
    if (icon == AppIcons.money ||
        name.contains('salary') ||
        name.contains('income') ||
        name.contains('freelance') ||
        name.contains('business') ||
        name.contains('transfer') ||
        name.contains('work')) {
      return _iconFor(brightness, const Color(0xFF2D9F63), const Color(0xFF3DD07B));
    }
    if (icon == AppIcons.health ||
        name.contains('health') ||
        name.contains('medical') ||
        name.contains('hospital') ||
        name.contains('gym') ||
        name.contains('workout') ||
        name.contains('fitness')) {
      return _iconFor(brightness, const Color(0xFFD94545), const Color(0xFFFF5C5C));
    }
    if (icon == AppIcons.car ||
        icon == AppIcons.flight ||
        name.contains('transport') ||
        name.contains('uber') ||
        name.contains('taxi') ||
        name.contains('car') ||
        name.contains('bus') ||
        name.contains('travel') ||
        name.contains('flight') ||
        name.contains('trip')) {
      return _iconFor(brightness, const Color(0xFFD49520), const Color(0xFFE8A830));
    }
    if (icon == AppIcons.food ||
        name.contains('food') ||
        name.contains('dining') ||
        name.contains('restaurant')) {
      return _iconFor(brightness, const Color(0xFFE6732A), const Color(0xFFF5873A));
    }
    if (icon == AppIcons.bag ||
        name.contains('shopping') ||
        name.contains('shop') ||
        name.contains('store') ||
        name.contains('bag') ||
        name.contains('grocery')) {
      return _iconFor(brightness, const Color(0xFF8853D6), const Color(0xFF9C6ADE));
    }
    if (icon == AppIcons.receipt ||
        name.contains('bill') ||
        name.contains('utility') ||
        name.contains('electric') ||
        name.contains('receipt') ||
        name.contains('util')) {
      return _iconFor(brightness, const Color(0xFF5566C4), const Color(0xFF6B7FD4));
    }
    if (icon == AppIcons.home ||
        name.contains('rent') ||
        name.contains('home') ||
        name.contains('house')) {
      return _iconFor(brightness, const Color(0xFF3D8BC4), const Color(0xFF5A9FDB));
    }
    if (icon == AppIcons.categories) {
      return _iconFor(brightness, const Color(0xFF4A7AD4), const Color(0xFF5A91E6));
    }
    if (icon == AppIcons.history) {
      return _iconHistory(brightness);
    }
    if (icon == AppIcons.analytics) {
      return _iconFor(brightness, const Color(0xFF5566C4), const Color(0xFF6B7FD4));
    }
    if (icon == AppIcons.budget) {
      return _iconFor(brightness, const Color(0xFF1FB85F), const Color(0xFF3DD07B));
    }
    if (icon == AppIcons.goals) {
      return _iconFor(brightness, const Color(0xFF8853D6), const Color(0xFF9C6ADE));
    }
    if (icon == AppIcons.repeat) {
      return _iconFor(brightness, const Color(0xFF5566C4), const Color(0xFF6B7FD4));
    }
    if (icon == AppIcons.download) {
      return _iconFor(brightness, const Color(0xFF3D8BC4), const Color(0xFF5A9FDB));
    }
    if (icon == AppIcons.upload) {
      return _iconFor(brightness, const Color(0xFFD49520), const Color(0xFFE8A830));
    }
    if (icon == AppIcons.personAdd || icon == AppIcons.user || icon == AppIcons.userRoundPlus || icon == AppIcons.usersRound) {
      return _iconFor(brightness, const Color(0xFF4A7AD4), const Color(0xFF5A91E6));
    }
    if (icon == AppIcons.edit) {
      return _iconFor(brightness, const Color(0xFF2D9F63), const Color(0xFF3DD07B));
    }
    if (icon == AppIcons.trash) {
      return _iconFor(brightness, const Color(0xFFD94545), const Color(0xFFF56B6B));
    }
    if (icon == AppIcons.chevronLeft || icon == AppIcons.chevronRight) {
      return _iconChevron(brightness);
    }
    if (type == TransactionType.income) {
      return AppColors.income;
    }
    if (type == TransactionType.expense) {
      return AppColors.expense;
    }
    if (type == TransactionType.investment) {
      return const Color(0xFF8B5CF6);
    }
    return _iconDefault(brightness);
  }
}
