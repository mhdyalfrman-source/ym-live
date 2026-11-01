import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/theme/color.dart';

class AppTheme {
  bool isAndroid = Platform.isAndroid;
  static TextTheme lightTextTheme() {
    return TextTheme(
      //MediaQuery.of(context).textScaler.scale
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: (22.r),
        fontFamily: 'cairo',
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: (28.r),
        fontFamily: 'cairo',
      ),
      headlineSmall: TextStyle(
        color: Colors.black,
        fontSize: (20.r),
        fontFamily: 'cairo',
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: (18.r),
        fontFamily: 'cairo',
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: (16.r),
        fontFamily: 'cairo',
      ),
      bodySmall: TextStyle(
        color: Colors.black,
        fontSize: (18.r),
        fontFamily: 'cairo',
      ),
      displayLarge: TextStyle(
        color: Colors.black,
        fontSize: (20.r),
        fontFamily: 'cairo',
      ),
      displayMedium: TextStyle(
        color: Colors.black,
        fontSize: (18.r),
        fontFamily: 'cairo',
      ),
      displaySmall: TextStyle(
        color: Colors.black,
        fontSize: (16.r),
        fontFamily: 'cairo',
      ),
      labelLarge: TextStyle(
        color: Colors.black,
        fontSize: (14.r),
        fontFamily: 'cairo',
      ),
      labelMedium: TextStyle(
        color: Colors.black,
        fontSize: (12.r),
        fontFamily: 'cairo',
      ),
      labelSmall: TextStyle(
        color: Colors.black,
        fontSize: (10.r),
        fontFamily: 'cairo',
      ),
    );
  }

  static TextTheme darkTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: (22.r),
        fontFamily: 'cairo',
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: (24.r),
        fontFamily: 'cairo',
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: (20.r),
        fontFamily: 'cairo',
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: (18.r),
        fontFamily: 'cairo',
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: (16.r),
        fontFamily: 'cairo',
      ),
      bodySmall: TextStyle(
        color: Colors.white,
        fontSize: (16.r),
        fontFamily: 'cairo',
      ),
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: (20.r),
        fontFamily: 'cairo',
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: (18.r),
        fontFamily: 'cairo',
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: (16.r),
        fontFamily: 'cairo',
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: (14.r),
        fontFamily: 'cairo',
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        fontSize: (12.r),
        fontFamily: 'cairo',
      ),
      labelSmall: TextStyle(
        color: Colors.white,
        fontSize: (10.r),
        fontFamily: 'cairo',
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: AppColors.primary,
      ),
      colorScheme: ColorScheme(
        secondaryContainer: Color(0xff666666),
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.gray100,
        onSecondary: Colors.white,
        error: AppColors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      dialogTheme: DialogThemeData(surfaceTintColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(fillColor: Color(0xffF4F6F9)),
      dialogBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      indicatorColor: AppColors.primary,
      primaryColorLight: Colors.white,
      primaryColorDark: Colors.black,
      // colorScheme: ColorScheme.dark(background: Colors.white),
      scaffoldBackgroundColor: Colors.white,
      secondaryHeaderColor: AppColors.primaryDark,
      // for app bar
      chipTheme: ChipThemeData(backgroundColor: Colors.black.withOpacity(0.3)),

      // for main appbar items shadow
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primary),
      ),
      // textTheme: AppTheme.lightTextTheme(),
      // GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      //     .apply(bodyColor: Colors.white),
      canvasColor: Colors.white,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        unselectedItemColor: Color(0xff252A34),
        selectedItemColor: AppColors.primary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      cardColor: AppColors.gray50,
      textTheme: AppTheme.lightTextTheme(),
      primaryColor: AppColors.primary,
      appBarTheme: AppBarTheme(
        shadowColor: Colors.black,
        color: AppColors.primary,
        titleTextStyle: AppTheme.lightTextTheme().displayLarge!.copyWith(
          color: Colors.white,
        ),
      ),
      shadowColor: AppColors.secondary.withOpacity(0.2),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        collapsedIconColor: Colors.black,
        textColor: Colors.black,
        iconColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerColor: Colors.black,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateColor.resolveWith(
            (states) => Colors.transparent,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateColor.resolveWith(
            (states) => AppColors.primary.withOpacity(0.05),
          ),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        hourMinuteColor: Colors.transparent,
        hourMinuteTextColor: Colors.black,
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      // for TABLE Border
    );
  }

  ///Dark theme
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      // textSelectionTheme: TextSelectionThemeData(
      //   selectionHandleColor: AppColors.primary
      // ),
      colorScheme: ColorScheme(
        secondaryContainer: Color(0xff666666),
        brightness: Brightness.light,
        primary: AppColors.primaryDark,
        onPrimary: Colors.white,
        secondary: Color(0xFF666666),
        onSecondary: Colors.white,
        error: AppColors.red,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      dialogTheme: DialogThemeData(surfaceTintColor: Colors.black),
      inputDecorationTheme: InputDecorationTheme(fillColor: Color(0xff666666)),
      secondaryHeaderColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Colors.white),
      ),
      primaryColorLight: Colors.grey.shade900,
      primaryColorDark: const Color.fromRGBO(200, 200, 200, 1),
      primaryColor: AppColors.primaryDark,
      // for app bar
      // primaryColor: Colors.grey.shade800,
      chipTheme: const ChipThemeData(backgroundColor: Colors.white),

      // for main appbar items shadow
      indicatorColor: AppColors.primaryDark,
      // colorScheme: ColorScheme.dark(background:Colors.black, ),
      scaffoldBackgroundColor: Colors.black,
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.primaryDark),
      ),
      // textTheme: AppTheme.lightTextTheme(),
      // GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      //     .apply(bodyColor: Colors.white),
      canvasColor: Color(0xff252A34),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        unselectedItemColor: Colors.white,
        selectedItemColor: Color(0xff42C3A7),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: AppTheme.darkTextTheme(),
      // primaryColor: primaryColor,
      cardColor: Colors.grey.shade900,
      appBarTheme: AppBarTheme(
        color: Colors.black,
        titleTextStyle: AppTheme.darkTextTheme().displayLarge!.copyWith(
          color: Colors.white,
        ),
      ),
      shadowColor: Colors.grey.withOpacity(0.2),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xff42C3A7),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        collapsedIconColor: Colors.white,
        textColor: Colors.white,
        iconColor: Color(0xff42C3A7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      buttonTheme: ButtonThemeData(hoverColor: Colors.red),
      dividerColor: Colors.white,
      // for TABLE Border
      timePickerTheme: TimePickerThemeData(
        hourMinuteColor: Colors.transparent,
        hourMinuteTextColor: Colors.white,
        backgroundColor: Colors.grey.shade800,
        dayPeriodTextColor: Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(width: 1, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      // dialogTheme: DialogTheme(
      //   titleTextStyle: AppTheme.lightTextTheme().displayLarge,
      //   backgroundColor: Colors.white
      // ),
      // dialogBackgroundColor: Colors.white
    );
  }
}
