import 'package:flutter/material.dart';

import '../models/db_credentials.dart';
import '../services/mongodb_service.dart';
import '../utils/validators.dart';

class DbCredentialsForm extends StatefulWidget {
  final DbCredentials? initialCredentials;
  final void Function(DbCredentials credentials) onSave;
  final String saveButtonLabel;

  const DbCredentialsForm({
    super.key,
    this.initialCredentials,
    required this.onSave,
    this.saveButtonLabel = 'Save & Connect',
  });

  @override
  State<DbCredentialsForm> createState() => _DbCredentialsFormState();
}

class _DbCredentialsFormState extends State<DbCredentialsForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _isAdvancedMode;

  // Simple mode controllers
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _dbNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  // Advanced mode controller
  late final TextEditingController _uriController;

  bool _obscurePassword = true;
  bool _isTesting = false;
  bool? _testResult;
  String? _testError;

  @override
  void initState() {
    super.initState();
    final creds = widget.initialCredentials;
    _isAdvancedMode = creds?.isAdvancedMode ?? false;
    _hostController = TextEditingController(text: creds?.host ?? '');
    _portController = TextEditingController(text: creds?.port ?? '27017');
    _dbNameController =
        TextEditingController(text: creds?.databaseName ?? 'finboard');
    _usernameController = TextEditingController(text: creds?.username ?? '');
    _passwordController = TextEditingController(text: creds?.password ?? '');
    _uriController = TextEditingController(text: creds?.rawUri ?? '');
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _dbNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _uriController.dispose();
    super.dispose();
  }

  DbCredentials _buildCredentials() {
    if (_isAdvancedMode) {
      return DbCredentials(
        isAdvancedMode: true,
        rawUri: _uriController.text.trim(),
      );
    }
    return DbCredentials(
      host: _hostController.text.trim(),
      port: _portController.text.trim(),
      databaseName: _dbNameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
      _testError = null;
    });

    final creds = _buildCredentials();
    final (success, error) =
        await MongoDbService().testConnection(creds.buildUri());

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testResult = success;
      _testError = error;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Connection successful!'
            : 'Connection failed: ${error ?? "Unknown error"}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_buildCredentials());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode toggle
          Row(
            children: [
              const Text('Advanced Mode',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Switch.adaptive(
                value: _isAdvancedMode,
                onChanged: (val) => setState(() {
                  _isAdvancedMode = val;
                  _testResult = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isAdvancedMode) ...[
            // Advanced: raw URI
            TextFormField(
              controller: _uriController,
              decoration: const InputDecoration(
                labelText: 'Connection URI',
                hintText: 'mongodb+srv://user:pass@cluster.mongodb.net/db',
                prefixIcon: Icon(Icons.link),
              ),
              validator: Validators.mongoUri,
              maxLines: 2,
            ),
          ] else ...[
            // Simple: individual fields
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host *',
                hintText: 'cluster0.abc123.mongodb.net',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
              validator: (v) => Validators.required(v, 'Host'),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '27017',
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: Validators.port,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dbNameController,
              decoration: const InputDecoration(
                labelText: 'Database Name *',
                hintText: 'finboard',
                prefixIcon: Icon(Icons.storage_outlined),
              ),
              validator: (v) => Validators.required(v, 'Database name'),
              autocorrect: false,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => Validators.required(v, 'Username'),
              autocorrect: false,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (v) => Validators.required(v, 'Password'),
            ),
          ],

          const SizedBox(height: 20),

          // Connection status indicator
          if (_testResult != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _testResult! ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _testResult! ? Icons.check_circle : Icons.error,
                    color: _testResult! ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testResult!
                          ? 'Connection successful'
                          : _testError ?? 'Connection failed',
                      style: TextStyle(
                        color: _testResult! ? Colors.green[800] : Colors.red[800],
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Test connection button
          OutlinedButton.icon(
            onPressed: _isTesting ? null : _testConnection,
            icon: _isTesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering),
            label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
          ),

          const SizedBox(height: 12),

          // Save button
          ElevatedButton(
            onPressed: _save,
            child: Text(widget.saveButtonLabel),
          ),
        ],
      ),
    );
  }
}
