import 'package:flutter/material.dart';
import 'pages/widget_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的数学课代表',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WidgetGallery(),
      debugShowCheckedModeBanner: false,
    );
  }
}
