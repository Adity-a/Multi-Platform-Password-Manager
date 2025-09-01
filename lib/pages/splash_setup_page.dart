import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';

class SplashSetupPage extends StatefulWidget {
  const SplashSetupPage({super.key});

  @override
  State<SplashSetupPage> createState() => _SplashSetupPageState();
}

class _SplashSetupPageState extends State<SplashSetupPage> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Master PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This PIN derives your encryption key. Do not forget it.'),
            const SizedBox(height: 16),
            TextField(
              controller: _pin1,
              decoration: const InputDecoration(labelText: 'New PIN / Password'),
              obscureText: true,
            ),
            TextField(
              controller: _pin2,
              decoration: const InputDecoration(labelText: 'Confirm PIN / Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                if (_pin1.text.isEmpty || _pin1.text != _pin2.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PINs do not match')),
                  );
                  return;
                }
                setState(() => _busy = true);
                await vault.createNewVault(_pin1.text);
                if (mounted) Navigator.of(context).pushReplacementNamed('/unlock');
              },
              child: _busy ? const CircularProgressIndicator() : const Text('Create Vault'),
            ),
          ],
        ),
      ),
    );
  }
}