import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Cores
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkBlue,
      brightness: Brightness.light,
      
    ),

    // Estilos de texto
    textTheme: GoogleFonts.konkhmerSleokchherTextTheme().copyWith(
      titleLarge: const TextStyle(fontSize: 20, color: Colors.white),
      titleMedium: const TextStyle(fontSize: 14, color: Colors.white),
      
      bodyLarge: const TextStyle(fontSize: 20, color: Colors.white),
      bodyMedium: const TextStyle(fontSize: 16, color: Colors.black),
      bodySmall: const TextStyle(fontSize: 8, color: Colors.white),

      // Especifico dos cards do calendário
      labelLarge: const TextStyle(fontSize: 24, color: Colors.white),
      labelSmall: const TextStyle(fontSize: 12, color: Colors.white)

    ),

    // Cards do calendário
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    ),

    // Botão para adicinar um novo hábito
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      foregroundColor: Colors.white,
      backgroundColor: AppColors.homePageIconColor,
      iconSize: 21 // TODO: Figma esta 42x42, entao precisa verificar o tamanho depois
    ),

    textButtonTheme: TextButtonThemeData(
      
    )



  );


}