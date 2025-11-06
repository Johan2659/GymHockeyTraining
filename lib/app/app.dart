import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import '../features/application/app_state_provider.dart';

class HockeyGymApp extends ConsumerWidget {
  const HockeyGymApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModeAsync = ref.watch(themeModeProvider);

    return themeModeAsync.when(
      data: (themeMode) => MaterialApp.router(
        title: 'Hockey Gym',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => MaterialApp(
        title: 'Hockey Gym',
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
      error: (_, __) => MaterialApp.router(
        title: 'Hockey Gym',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
