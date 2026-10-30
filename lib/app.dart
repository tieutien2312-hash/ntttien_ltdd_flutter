import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Điểm Danh Sinh Viên',
            theme: themeProvider.getThemeData(),
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeProvider.fontScale),
                ),
                child: widget!,
              );
            },
          );
        },
      ),
    );
  }
}
