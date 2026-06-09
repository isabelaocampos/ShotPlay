import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Fondo y Bases
  static const Color background = Color(0xFF0E1018);
  static const Color cardBackground = Color(0xFF110B18);
  static const Color surface = Color(0xFF120818);
  
  // Primarios y Acentos (Neon)
  static const Color primary = Color(0xFF07FCFE); // Cyan
  static const Color secondary = Color(0xFFBAFA5E); // Lime
  static const Color accentPink = Color(0xFFFFBDF5);
  static const Color accentYellow = Color(0xFFFEE967);
  static const Color accentPurple = Color(0xFFA020F0);
  static const Color accentHotPink = Color(0xFFFF69B4);

  // Estados
  static const Color error = Color(0xFFFF3333);
  static const Color warning = Color(0xFFF97316);
  static const Color success = Color(0xFFBAFA5E);
  static const Color info = Color(0xFF07FCFE);

  // Elementos del Tablero
  static const Color snakeBody = accentPurple;
  static const Color snakeGlow = accentHotPink;
  static const Color ladderRail = Color(0xFFFFA726);
  static const Color ladderStep = Color(0xFFFFCC02);
  static const Color ladderGlow = Color(0xFFFF6D00);

  // Texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textContrast = Color(0xFF120818);

  // Tokens de Jugadores
  static const List<Color> playerTokens = [
    Color(0xFFBFFBF9),
    Color(0xFFFEE967),
    Color(0xFFFFBDF5),
    Color(0xFFBAFA5E),
  ];

  // Células Especiales
  static const Color cellShot = Color(0xFFBAFA5E);
  static const Color cellTruth = Color(0xFFFFBDF5);
  static const Color cellRevenge = Color(0xFFFF339A);
  static const Color cellTrap = Color(0xFFF97316);
  static const Color cellSpecialBase = Color(0xFFA50EEB);
}