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

    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBlue,
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0
    ),

    // Estilos de texto
    textTheme: GoogleFonts.konkhmerSleokchherTextTheme().copyWith(
      titleLarge: const TextStyle(fontSize: 20, color: AppColors.whiteText),
      titleMedium: const TextStyle(fontSize: 14, color: AppColors.whiteText), // Titulo do listTile dos habitos
      
      bodyLarge: const TextStyle(fontSize: 20, color: AppColors.whiteText),
      bodyMedium: const TextStyle(fontSize: 16, color: Colors.black),
      bodySmall: const TextStyle(fontSize: 8, color: AppColors.whiteText), // Descricao do listTile dos habitos

      // Especifico dos cards do calendário
      labelLarge: const TextStyle(fontSize: 24, color: AppColors.whiteText),
      labelSmall: const TextStyle(fontSize: 12, color: AppColors.whiteText),

      // Especifico para os textbuttons do bottomnavbar
      labelMedium: const TextStyle(fontSize: 18, color: AppColors.whiteText, fontWeight: FontWeight.bold)

    ),

    // Cor dos Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.alertDialogBGColor,
      elevation: 4,

    ),
    

    // Cards do calendário
    cardTheme: CardThemeData(
      color: AppColors.cardBackgrounColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      sizeConstraints: BoxConstraints(
        minWidth: 62,
        minHeight: 62
      ),
      foregroundColor: Colors.white,
      backgroundColor: AppColors.homePageIconColor,
      iconSize: 48
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,    

        )
      )
      
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.dialogTextColor, 
      selectedColor: AppColors.positiveActionDialogTextColor, 
      checkmarkColor: Colors.white, 
      side: const BorderSide(color: Colors.transparent),
    ),
  );

}