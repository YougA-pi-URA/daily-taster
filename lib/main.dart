import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskProvider = TaskProvider();
  await taskProvider.init();
  runApp(DailyTaskerApp(taskProvider: taskProvider));
}

class DailyTaskerApp extends StatelessWidget {
  final TaskProvider taskProvider;
  const DailyTaskerApp({super.key, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: taskProvider,
      child: MaterialApp(
        title: 'Daily Tasker',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
