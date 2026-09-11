import 'package:flutter/material.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';

class AppTheme {
  static const _defaultButtonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );
  static const _defaultButtonSize = Size(double.infinity, 50);
  static const _defaultBorderRadius = 15.0;
  static const _defaultTextFontSize = 16.0;
  static const _defaultLabelFontSize = 14.0;
  static const _defaultTitleFontSize = 20.0;

  static ThemeData get lightTheme => _baseTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    surfaceColor: Colors.white,
    onSurfaceColor: AppColors.lightText,
    appBarBackground: AppColors.lightAppBar,
    appBarTextColor: AppColors.secondary,
    textColor: Colors.black87,
    fillColor: Colors.white,
    inputBorderColor: Colors.grey[300]!,
    errorColor: Colors.red[700]!,
    cardColor: Colors.white,
    chipBackgroundColor: Colors.grey[100]!,
    chipSelectedColor: ColorUtils.applyOpacity(AppColors.primary, 0.2),
    dividerColor: Colors.grey[300]!,
    switchTrackColor: Colors.grey[300]!,
    sliderInactiveColor: Colors.grey[300]!,
    dropdownFillColor: Colors.white,
    snackbarBackgroundColor: Colors.grey[800]!,
    dialogBackgroundColor: Colors.white,
  );

  static ThemeData get darkTheme => _baseTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    surfaceColor: AppColors.darkAppBar,
    onSurfaceColor: ColorUtils.applyOpacity(AppColors.darkText, 0.87),
    appBarBackground: Colors.transparent,
    appBarTextColor: AppColors.secondary,
    textColor: ColorUtils.applyOpacity(Colors.white, 0.87),
    fillColor: const Color(0xFF2A2A2A),
    inputBorderColor: Colors.grey[700]!,
    errorColor: Colors.red[400]!,
    cardColor: const Color(0xFF2A2A2A),
    chipBackgroundColor: const Color(0xFF333333),
    chipSelectedColor: ColorUtils.applyOpacity(AppColors.primary, 0.3),
    dividerColor: Colors.grey[700]!,
    switchTrackColor: Colors.grey[700]!,
    sliderInactiveColor: Colors.grey[700]!,
    dropdownFillColor: const Color(0xFF2A2A2A),
    snackbarBackgroundColor: const Color(0xFF333333),
    dialogBackgroundColor: const Color(0xFF2A2A2A),
  );

  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color appBarBackground,
    required Color appBarTextColor,
    required Color textColor,
    required Color fillColor,
    required Color inputBorderColor,
    required Color errorColor,
    required Color cardColor,
    required Color chipBackgroundColor,
    required Color chipSelectedColor,
    required Color dividerColor,
    required Color switchTrackColor,
    required Color sliderInactiveColor,
    required Color dropdownFillColor,
    required Color snackbarBackgroundColor,
    required Color dialogBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurfaceColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: _defaultTitleFontSize,
          fontWeight: FontWeight.bold,
          color: appBarTextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
          ),
          padding: _defaultButtonPadding,
          elevation: 2,
          minimumSize: _defaultButtonSize,
          textStyle: const TextStyle(
            fontSize: _defaultTextFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: _defaultLabelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(
            color: ColorUtils.applyOpacity(AppColors.primary, 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
        errorStyle: TextStyle(color: errorColor, fontSize: 12),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
        labelLarge: TextStyle(
          fontSize: _defaultTextFontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
        ),
        color: cardColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackbarBackgroundColor,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBackgroundColor,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontSize: _defaultTitleFontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackgroundColor,
        selectedColor: chipSelectedColor,
        labelStyle: TextStyle(
          fontSize: _defaultLabelFontSize,
          color: textColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: dropdownFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
            borderSide: BorderSide(color: inputBorderColor),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 20,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.grey[400],
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? ColorUtils.applyOpacity(AppColors.primary, 0.4)
                  : switchTrackColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: ColorUtils.applyOpacity(textColor, 0.6),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: sliderInactiveColor,
        thumbColor: AppColors.primary,
        overlayColor: ColorUtils.applyOpacity(AppColors.primary, 0.2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
