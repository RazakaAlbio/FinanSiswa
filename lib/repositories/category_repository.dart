import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas/models/category.dart';
import 'package:uas/models/transaction.dart';

class CategoryRepository {
  static const _keyCategories = 'categories_v1';

  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_keyCategories);

    if (jsonStr == null) {
      // Seed default categories
      final defaults = _getDefaultCategories();
      await saveCategories(defaults);
      return defaults;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => Category.fromMap(e)).toList();
    } catch (e) {
      return _getDefaultCategories();
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(categories.map((e) => e.toMap()).toList());
    await prefs.setString(_keyCategories, jsonStr);
  }

  Future<void> addCategory(Category category) async {
    final current = await getCategories();
    current.add(category);
    await saveCategories(current);
  }

  Future<void> updateCategory(Category category) async {
    final current = await getCategories();
    final index = current.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      current[index] = category;
      await saveCategories(current);
    }
  }

  Future<void> deleteCategory(String id) async {
    final current = await getCategories();
    current.removeWhere((c) => c.id == id);
    await saveCategories(current);
  }

  List<Category> _getDefaultCategories() {
    return [
      // Expense
      Category(
        id: 'def_food',
        name: 'Makanan',
        type: TransactionType.expense,
        iconCode: Icons.restaurant.codePoint,
        colorValue: Colors.orange.value,
      ),
      Category(
        id: 'def_transport',
        name: 'Transportasi',
        type: TransactionType.expense,
        iconCode: Icons.directions_bus.codePoint,
        colorValue: Colors.blue.value,
      ),
      Category(
        id: 'def_ent',
        name: 'Hiburan',
        type: TransactionType.expense,
        iconCode: Icons.movie.codePoint,
        colorValue: Colors.pink.value,
      ),
      Category(
        id: 'def_health',
        name: 'Kesehatan',
        type: TransactionType.expense,
        iconCode: Icons.local_hospital.codePoint,
        colorValue: Colors.red.value,
      ),
      Category(
        id: 'def_edu',
        name: 'Akademik',
        type: TransactionType.expense,
        iconCode: Icons.school.codePoint,
        colorValue: Colors.purple.value,
      ),
      
      // Income
      Category(
        id: 'def_allowance',
        name: 'Uang Saku',
        type: TransactionType.income,
        iconCode: Icons.attach_money.codePoint,
        colorValue: Colors.green.value,
      ),
      Category(
        id: 'def_bonus',
        name: 'Bonus',
        type: TransactionType.income,
        iconCode: Icons.card_giftcard.codePoint,
        colorValue: Colors.teal.value,
      ),
    ];
  }
}
