import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../widgets/password_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final items = vault.entries
        .where((e) => e.title.toLowerCase().contains(_query.toLowerCase()) ||
        e.username.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/edit');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by title or username',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = items[i];
                return PasswordTile(entry: e);
              },
            ),
          ),
          /*
          if (vault.isDirty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  onPressed: () async {
                    await vault.save();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vault saved')),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ),*/
        ],
      ),
    );
  }
}