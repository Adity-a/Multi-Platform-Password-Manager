import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/biometric_service.dart';
import '../services/vault_service.dart';
import '../services/secure_storage_service.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _pin = TextEditingController();
  final _bio = BiometricService();
  final _storage = SecureStorageService();
  bool _bioAvailable = false;
  bool _bioFailedOrCanceled = false;

  @override
  void initState() {
    super.initState();
    _checkBio();
  }

  Future<void> _checkBio() async {
    _bioAvailable = await _bio.canCheck();
    if (mounted) setState(() {});
    if (_bioAvailable) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final vault = context.read<VaultService>();
    final ok = await _bio.authenticate();
    if (ok) {
      // retrieve stored pin
      final savedPin = await _storage.getPin();
      if (savedPin != null) {
        final unlocked = await vault.unlock(savedPin);
        if (unlocked && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }
      }

      // fallback if no PIN saved
      if (mounted) {
        setState(() {
          _bioFailedOrCanceled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved PIN found, please enter manually')),
        );
      }
    } else {
      // biometrics canceled or failed
      if (mounted) {
        setState(() {
          _bioFailedOrCanceled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric auth failed, use PIN or try again')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Vault')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_bioAvailable || _bioFailedOrCanceled) ...[
              TextField(
                controller: _pin,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Master PIN / Password'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final ok = await vault.unlock(_pin.text);
                        if (ok && mounted) {
                          // save pin for future biometric unlock
                          await _storage.savePin(_pin.text);
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid PIN')),
                            );
                          }
                        }
                      },
                      child: const Text('Unlock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_bioAvailable)
                    IconButton(
                      icon: const Icon(Icons.fingerprint),
                      onPressed: _tryBiometric,
                    ),
                ],
              ),
            ] else ...[
              const Text(
                'Authenticating with biometrics...',
                style: TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                if (!await vault.vaultExists()) {
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/setup');
                  }
                }
              },
              child: const Text('First time here? Create a vault'),
            ),
          ],
        ),
      ),
    );
  }
}