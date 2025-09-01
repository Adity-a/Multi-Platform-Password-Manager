import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../pages/edit_entry_page.dart';
import '../services/vault_service.dart';
import '../services/biometric_service.dart';

class PasswordTile extends StatelessWidget {
  final PasswordEntry entry;
  const PasswordTile({super.key, required this.entry});

  Future<bool> _authenticate(BuildContext context) async {
    final bio = BiometricService();
    final vault = context.read<VaultService>();

    // Try biometrics first
    final canUseBio = await bio.canCheck();
    if (canUseBio) {
      final ok = await bio.authenticate();
      if (ok) return true;
    }

    // Fallback → PIN dialog
    final pinController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter PIN"),
        content: TextField(
          controller: pinController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Master PIN"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final success = await vault.unlock(pinController.text);
              Navigator.pop(context, success);
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );

    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.title),
      subtitle: Text(entry.username),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy button (no auth needed)
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: entry.password));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied for 20s')),
                );
              }
              Future.delayed(const Duration(seconds: 20), () async {
                final current = await Clipboard.getData('text/plain');
                if (current?.text == entry.password) {
                  await Clipboard.setData(const ClipboardData(text: ''));
                }
              });
            },
          ),

          // Edit button with auth
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final ok = await _authenticate(context);
              if (!ok) return;

              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditEntryPage(initial: entry),
              ));
            },
          ),

          // Delete button with auth
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final okAuth = await _authenticate(context);
              if (!okAuth) return;

              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete?'),
                  content: Text('Delete ${entry.title}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (ok == true && context.mounted) {
                final vault = context.read<VaultService>();
                vault.remove(entry.id);
                await vault.save();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}