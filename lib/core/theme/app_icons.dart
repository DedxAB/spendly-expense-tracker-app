import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

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

  static Color getColorForCategory(
    String categoryName, [
    TransactionType? type,
  ]) {
    return getColorForIcon(
      getIconForCategory(categoryName, type),
      label: categoryName,
      type: type,
    );
  }

  static Color getColorForIcon(
    IconData icon, {
    String? label,
    TransactionType? type,
  }) {
    final name = label?.toLowerCase() ?? '';

    if (icon == AppIcons.bell || name.contains('notification')) {
      return const Color(0xFFFFC857);
    }
    if (icon == AppIcons.shield) {
      return const Color(0xFF57C98B);
    }
    if (icon == AppIcons.money ||
        name.contains('salary') ||
        name.contains('income') ||
        name.contains('freelance') ||
        name.contains('business') ||
        name.contains('transfer') ||
        name.contains('work')) {
      return const Color(0xFF57C98B);
    }
    if (icon == AppIcons.health ||
        name.contains('health') ||
        name.contains('medical') ||
        name.contains('hospital') ||
        name.contains('gym') ||
        name.contains('workout') ||
        name.contains('fitness')) {
      return const Color(0xFFFF7A7A);
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
      return const Color(0xFFF5C35C);
    }
    if (icon == AppIcons.food ||
        name.contains('food') ||
        name.contains('dining') ||
        name.contains('restaurant')) {
      return const Color(0xFFFF9A57);
    }
    if (icon == AppIcons.bag ||
        name.contains('shopping') ||
        name.contains('shop') ||
        name.contains('store') ||
        name.contains('bag') ||
        name.contains('grocery')) {
      return const Color(0xFFB58CFF);
    }
    if (icon == AppIcons.receipt ||
        name.contains('bill') ||
        name.contains('utility') ||
        name.contains('electric') ||
        name.contains('receipt') ||
        name.contains('util')) {
      return const Color(0xFF8EA0FF);
    }
    if (icon == AppIcons.home ||
        name.contains('rent') ||
        name.contains('home') ||
        name.contains('house')) {
      return const Color(0xFF8BC8FF);
    }
    if (icon == AppIcons.categories) {
      return const Color(0xFF82B1FF);
    }
    if (icon == AppIcons.history) {
      return const Color(0xFFBDBDBD);
    }
    if (icon == AppIcons.analytics) {
      return const Color(0xFF8EA0FF);
    }
    if (icon == AppIcons.budget) {
      return const Color(0xFF57F28F);
    }
    if (icon == AppIcons.goals) {
      return const Color(0xFFB58CFF);
    }
    if (icon == AppIcons.repeat) {
      return const Color(0xFF8EA0FF);
    }
    if (icon == AppIcons.download) {
      return const Color(0xFF8BC8FF);
    }
    if (icon == AppIcons.upload) {
      return const Color(0xFFF5C35C);
    }
    if (icon == AppIcons.personAdd || icon == AppIcons.user) {
      return const Color(0xFF82B1FF);
    }
    if (icon == AppIcons.edit) {
      return const Color(0xFF57C98B);
    }
    if (icon == AppIcons.trash) {
      return const Color(0xFFFF8D8D);
    }
    if (icon == AppIcons.chevronLeft || icon == AppIcons.chevronRight) {
      return const Color(0xFFD0D0D0);
    }
    if (type == TransactionType.income) {
      return AppColors.income;
    }
    if (type == TransactionType.expense) {
      return AppColors.expense;
    }
    return const Color(0xFFCFCFCF);
  }
}
