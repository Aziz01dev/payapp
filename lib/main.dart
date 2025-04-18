import 'package:flutter/material.dart';
import 'package:pay_app/view/home_page.dart';
import 'package:pay_app/view_models/payapp_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PayappViewModel().init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
