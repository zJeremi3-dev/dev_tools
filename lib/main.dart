import 'colors.dart';
import 'app/home_page.dart';
import 'state/providers.dart';
import 'package:flutter/material.dart';
import "package:flutter_native_splash/flutter_native_splash.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(toolsControllerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBgColor,
        colorScheme: ColorScheme.dark(
          surface: kSurfaceColor,
          primary: kAccent,
          secondary: kAccentLight,
        ),
        cardTheme: CardThemeData(
          color: kSurfaceColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.selected) ? kAccent : Colors.transparent,
          ),
          side: BorderSide(color: kTextSecondary, width: 1.5),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: kAccent,
          inactiveTrackColor: kAccent.withAlpha(60),
          thumbColor: kAccentLight,
          overlayColor: kAccent.withAlpha(30),
          trackHeight: 3,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kBgColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: kAccentLight),
        ),
      ),
      home: const MyHomePage(title: "Dev-Tools"),
    );
  }
}
