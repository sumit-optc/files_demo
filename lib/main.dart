import 'package:flutter/material.dart';
import 'file_reader_screen.dart';

void main() {
  runApp(const PCFileReaderApp());
}

class PCFileReaderApp extends StatelessWidget {
  const PCFileReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC File Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FileReaderScreen(),
    );
  }
}
