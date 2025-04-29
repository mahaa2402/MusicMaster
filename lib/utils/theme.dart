import 'package:flutter/material.dart';
import 'package:my_music_stream/utils/constants.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.cardBackground,
  ),
  textTheme: TextTheme(
    // Updated TextTheme with new Material 3 names
    displayLarge: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      color: AppColors.white,
    ),
    titleSmall: TextStyle(
      color: AppColors.lightGrey,
    ),
    bodyLarge: TextStyle(
      color: AppColors.white,
    ),
    bodyMedium: TextStyle(
      color: AppColors.lightGrey,
    ),
    bodySmall: TextStyle(
      color: AppColors.lightGrey,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackground,
    labelStyle: TextStyle(color: AppColors.lightGrey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary, // Changed primary to backgroundColor
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary, // Changed primary to foregroundColor
    ),
  ),
  iconTheme: IconThemeData(
    color: AppColors.white,
  ),
  cardTheme: CardTheme(
    color: AppColors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);
