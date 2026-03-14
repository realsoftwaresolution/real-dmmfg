
import 'package:diam_mfg/providers/menu_provider.dart';
import 'package:diam_mfg/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {

        if (menuProvider.isLoading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          title: 'RS Dashboard Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          //
          // home: DashboardLayout(
          //   menu: menuProvider.menus,
          //   router: AppRouter.router,
          // ),
          home: const SplashScreenV7(), // 🎨 Design 1 (Dark Orbs)

        );
      },
    );
  }
}
