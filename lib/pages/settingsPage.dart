import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('Appearance'),
            subtitle: Text('Choose Light, Dark, or System theme'),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('System Default'),
            value: AppThemeMode.system,
            groupValue: themeProvider.mode,
            onChanged: (val) => themeProvider.setMode(val!),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Light Mode'),
            value: AppThemeMode.light,
            groupValue: themeProvider.mode,
            onChanged: (val) => themeProvider.setMode(val!),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark Mode'),
            value: AppThemeMode.dark,
            groupValue: themeProvider.mode,
            onChanged: (val) => themeProvider.setMode(val!),
          ),
          const Divider(),

          /// Export Backup
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export encrypted backup'),
            subtitle: const Text('Pick a location to save your encrypted vault'),
            onTap: () async {
              try {
                await vault.exportEncryptedBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup exported successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),

          /// Import Backup
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import encrypted backup'),
            subtitle: const Text('Select a backup file to replace current vault'),
            onTap: () async {
              final controller = TextEditingController();
              final pin = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Enter master PIN for backup'),
                  content: TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Master PIN',
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: const Text('Import')),
                  ],
                ),
              );

              if (pin == null || pin.isEmpty) return;

              final ok = await vault.importEncryptedBackup(pin);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          ok ? 'Backup imported successfully' : 'Failed to import')),
                );
              }
            },
          ),
          const Divider(),

          /// Lock Vault
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Lock vault'),
            onTap: () => vault.lock(),
          ),
        ],
      ),
    );
  }
}