import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/vault_service.dart';
import '../utils/password_utils.dart';

class EditEntryPage extends StatefulWidget {
  final PasswordEntry? initial;
  const EditEntryPage({super.key, this.initial});

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  final _title = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _url = TextEditingController();
  final _note = TextEditingController();

  bool _obscurePassword = true; // for show/hide toggle

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _title.text = e.title;
      _username.text = e.username;
      _password.text = e.password;
      //_url.text = e.url ?? '';
      //_note.text = e.note ?? '';
    }
  }

  void _generatePassword() {
    final newPassword = PasswordUtils.generate(length: 16);
    setState(() {
      _password.text = newPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'Add Entry' : 'Edit Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title *')),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username *')),

          // Password field with show/hide and refresh
          TextField(
            controller: _password,
            decoration: InputDecoration(
              labelText: 'Password *',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generatePassword,
                  ),
                ],
              ),
            ),
            obscureText: _obscurePassword,
          ),

          //TextField(controller: _url, decoration: const InputDecoration(labelText: 'URL')),
          //TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note'), maxLines: 3),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: () async {
              if (_title.text.isEmpty || _username.text.isEmpty || _password.text.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                return;
              }

              final e = widget.initial ?? PasswordEntry(
                id: const Uuid().v4(),
                title: _title.text,
                username: _username.text,
                password: _password.text,
                //url: _url.text.isEmpty ? null : _url.text,
                //note: _note.text.isEmpty ? null : _note.text,
              );

              if (widget.initial != null) {
                e.title = _title.text;
                e.username = _username.text;
                e.password = _password.text;
                //e.url = _url.text.isEmpty ? null : _url.text;
                //e.note = _note.text.isEmpty ? null : _note.text;
              }

              vault.addOrUpdate(e);
              await vault.save();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
