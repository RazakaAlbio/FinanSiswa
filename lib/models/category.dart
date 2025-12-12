import 'package:flutter/material.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/utils/icon_helper.dart';

class Category {
  final String id;
  final String name;
  final TransactionType type;
  final int iconCode; // Store IconData.codePoint
  final int colorValue; // Store Color.value

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
  });

  IconData get icon => IconHelper.getIcon(iconCode);
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: TransactionType.values[map['type']],
      iconCode: map['iconCode'],
      colorValue: map['colorValue'],
    );
  }
}
