import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heads_upp/category_selection.dart';
import 'package:heads_upp/db%20state%20management/head_up_logic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HeadsUplogic>(
            create: (context) => HeadsUplogic()..createDatabaseAndTables(),
          ),

          // Add other Bloc providers here if needed
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: CategorySelectionScreen(),
        ));
  }
}
