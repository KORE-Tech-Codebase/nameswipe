import 'package:flutter/material.dart';

abstract final class CardGradients {
  static const List<List<Color>> _gradients = [
    [Color(0xFFFF6B35), Color(0xFFFF4081)],   // orange -> pink
    [Color(0xFF00BFA6), Color(0xFF00B0FF)],   // teal -> blue
    [Color(0xFF7C4DFF), Color(0xFFFF4081)],   // purple -> pink
    [Color(0xFFFF6D00), Color(0xFFFFAB00)],   // orange -> amber
    [Color(0xFF00BFA6), Color(0xFF69F0AE)],   // teal -> green
    [Color(0xFF304FFE), Color(0xFF00B0FF)],   // indigo -> blue
    [Color(0xFFE91E63), Color(0xFFFF80AB)],   // pink -> light pink
    [Color(0xFF6200EA), Color(0xFFAA00FF)],   // deep purple -> purple
  ];

  static LinearGradient forCategory(String category) {
    final index = category.hashCode.abs() % _gradients.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _gradients[index],
    );
  }

  static LinearGradient forIndex(int index) {
    final i = index.abs() % _gradients.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _gradients[i],
    );
  }

  static List<Color> colorsForCategory(String category) {
    final index = category.hashCode.abs() % _gradients.length;
    return _gradients[index];
  }
}
