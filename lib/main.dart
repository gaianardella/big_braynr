import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 aggiunto dotenv
import 'app_shell.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica il file .env
  await dotenv.load();

  // Imposta la barra di stato per tema scuro
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: StudyApp(),
    ),
  );
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BraynR Studio',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      darkTheme: _buildAppTheme(isDark: true),
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }

  ThemeData _buildAppTheme({bool isDark = true}) {
    final isDarkTheme = isDark;

    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
      canvasColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
      colorScheme: ColorScheme.fromSeed(
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        background: isDarkTheme ? AppColors.darkBackground : Colors.white,
        surface: isDarkTheme ? AppColors.cardDark : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? AppColors.cardDark : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.border : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.border : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDarkTheme ? AppColors.textMedium : Colors.grey.shade500,
        ),
        labelStyle: TextStyle(
          color: isDarkTheme ? AppColors.textMedium : Colors.grey.shade700,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isDarkTheme ? AppColors.textMedium : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: isDarkTheme ? AppColors.cardDark : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkTheme ? AppColors.border : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: AppColors.shadow,
      ),
      dividerTheme: DividerThemeData(
        color: isDarkTheme ? AppColors.divider : Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? AppColors.cardDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
        ),
        titleTextStyle: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDarkTheme ? AppColors.cardDark.withOpacity(0.9) : Colors.grey.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDarkTheme ? AppColors.backgroundGrey : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDarkTheme ? AppColors.backgroundGrey : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          color: isDarkTheme ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? AppColors.cardDark : Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: isDarkTheme ? AppColors.textMedium : Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      useMaterial3: true,
    );
  }
}
