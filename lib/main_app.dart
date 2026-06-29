
import 'package:diam_mfg/screens/login_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIAMOND MFG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      actions: <Type, Action<Intent>>{
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (intent) {
            FocusManager.instance.primaryFocus?.unfocus();
            return null;
          },
        ),
      },
      home: const LoginScreenV7(),
    );
  }
}
