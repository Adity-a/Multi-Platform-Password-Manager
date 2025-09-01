import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/password_entry.dart';
import 'pages/edit_entry_page.dart';
import 'pages/home_page.dart';
import 'pages/splash_setup_page.dart';
import 'pages/unlock_page.dart';
import 'pages/settingsPage.dart';
import 'services/vault_service.dart';
import 'themes/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Password Manager',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6750A4),
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: '/bootstrap',
            routes: {
              '/bootstrap': (ctx) => const _Bootstrapper(),
              '/setup': (ctx) => const SplashSetupPage(),
              '/unlock': (ctx) => const UnlockPage(),
              '/home': (ctx) => const HomePage(),
              '/settings': (ctx) => const SettingsPage(),
              '/edit': (ctx) => const EditEntryPage(),
            },
          );
        },
      ),
    );
  }
}

class _Bootstrapper extends StatefulWidget {
  const _Bootstrapper();

  @override
  State<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<_Bootstrapper> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final vault = context.read<VaultService>(); // use provider instance
    final exists = await vault.vaultExists();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(exists ? '/unlock' : '/setup');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}