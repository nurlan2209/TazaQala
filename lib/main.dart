import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/screens/home_screen.dart';
import 'package:tazaqala/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadSession();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        title: 'TazaQala',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Roboto',
        ),
        home:
            authProvider.isAuthenticated ? const HomeScreen() : const AuthScreen(),
      ),
    );
  }
}
