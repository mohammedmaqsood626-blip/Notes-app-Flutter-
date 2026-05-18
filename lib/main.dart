import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'services/notes_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider()..loadNotes(),
      child: const NoteFlowApp(),
    ),
  );
}

class NoteFlowApp extends StatelessWidget {
  const NoteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoteFlow',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
