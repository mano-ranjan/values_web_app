import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:values_web_app/features/home/presentation/pages/home_page.dart';
import 'package:values_web_app/features/home/presentation/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vswnpmyjvwpidoxfneed.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzd25wbXlqdndwaWRveGZuZWVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcwMjQwNTQsImV4cCI6MjA2MjYwMDA1NH0.tLb174oRfBoCGfL_qMJXO-x8zLyjh8NzE29_MEntAiU', // Replace with your Supabase anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeInitialized()),
      child: MaterialApp(
        title: 'College Website',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder:
            (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
        home: HomePage(),
      ),
    );
  }
}
