import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/db_credentials.dart';
import '../../services/mongodb_service.dart';
import '../../services/secure_storage_service.dart';
import '../../widgets/db_credentials_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = SecureStorageService();
  DbCredentials? _currentCredentials;
  List<String> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final creds = await _storage.getCredentials();
    final cats = await _storage.getCustomCategories();
    if (!mounted) return;
    setState(() {
      _currentCredentials = creds;
      _customCategories = cats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // === Database Credentials ===
        _SectionHeader(title: 'Database'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection status
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MongoDbService().isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      MongoDbService().isConnected
                          ? 'Connected'
                          : 'Disconnected',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: MongoDbService().isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (_currentCredentials != null && !_currentCredentials!.isAdvancedMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Host: ${_currentCredentials!.host}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    'Database: ${_currentCredentials!.databaseName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    'User: ${_currentCredentials!.username}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editCredentials,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _disconnect,
                        icon: const Icon(Icons.link_off, size: 18,
                            color: Colors.red),
                        label: const Text('Disconnect',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // === Expense Categories ===
        _SectionHeader(title: 'Expense Categories'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default categories',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AppConstants.defaultCategories
                      .map((c) => Chip(
                            label: Text(c, style: const TextStyle(fontSize: 12)),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
                if (_customCategories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Custom categories',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _customCategories
                        .map((c) => Chip(
                              label:
                                  Text(c, style: const TextStyle(fontSize: 12)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeCategory(c),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Category'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // === App Info ===
        _SectionHeader(title: 'About'),
        Card(
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FinBoard',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 4),
                Text('Version 0.1.0',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 4),
                Text(
                  'Personal financial tracker with direct MongoDB connection.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _editCredentials() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Database Credentials',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              DbCredentialsForm(
                initialCredentials: _currentCredentials,
                saveButtonLabel: 'Save & Reconnect',
                onSave: (creds) => _saveCredentials(ctx, creds),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCredentials(
      BuildContext sheetContext, DbCredentials creds) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await MongoDbService().disconnect();
    final uri = creds.buildUri();
    final connected = await MongoDbService().connect(uri);

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (connected) {
      await _storage.saveCredentials(creds);
      if (!mounted) return;
      Navigator.of(sheetContext).pop(); // dismiss bottom sheet
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection failed: ${MongoDbService().lastError ?? "Unknown error"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect?'),
        content: const Text(
          'This will clear your saved credentials. '
          'You\'ll need to re-enter them to reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await MongoDbService().disconnect();
    await _storage.clearCredentials();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.setup,
      (route) => false,
    );
  }

  void _addCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                _customCategories.add(name);
                _storage.saveCustomCategories(_customCategories);
                setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCategory(String category) {
    _customCategories.remove(category);
    _storage.saveCustomCategories(_customCategories);
    setState(() {});
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1.2,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
