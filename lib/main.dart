import 'package:flutter/material.dart';
import 'screen/task_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tareas APP',
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false,
      //home: const MyHomePage(title: 'Manejo de Tareas'),
    );
  }
}