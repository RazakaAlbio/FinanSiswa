import 'package:flutter/material.dart';

class IconHelper {
  static final Map<int, IconData> _iconMap = {
    // Categories
    Icons.restaurant.codePoint: Icons.restaurant,
    Icons.directions_bus.codePoint: Icons.directions_bus,
    Icons.movie.codePoint: Icons.movie,
    Icons.local_hospital.codePoint: Icons.local_hospital,
    Icons.school.codePoint: Icons.school,
    Icons.shopping_bag.codePoint: Icons.shopping_bag,
    Icons.sports_soccer.codePoint: Icons.sports_soccer,
    Icons.flight.codePoint: Icons.flight,
    Icons.home.codePoint: Icons.home,
    Icons.work.codePoint: Icons.work,
    Icons.pets.codePoint: Icons.pets,
    Icons.wifi.codePoint: Icons.wifi,
    Icons.phone.codePoint: Icons.phone,
    Icons.attach_money.codePoint: Icons.attach_money,
    Icons.card_giftcard.codePoint: Icons.card_giftcard,
    Icons.savings.codePoint: Icons.savings,
    Icons.category.codePoint: Icons.category, // Default/Fallack?

    // Articles
    Icons.fastfood.codePoint: Icons.fastfood,
    Icons.payments.codePoint: Icons.payments,
    Icons.bar_chart.codePoint: Icons.bar_chart,
    Icons.card_travel.codePoint: Icons.card_travel,
    Icons.health_and_safety.codePoint: Icons.health_and_safety,
    
    // Additional defaults if needed
    Icons.help.codePoint: Icons.help,
  };

  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.help;
  }
}
