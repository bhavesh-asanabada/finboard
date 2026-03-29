import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../models/db_credentials.dart';
import '../services/mongodb_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/db_credentials_form.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to FinBoard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your MongoDB database to get started. '
                'Your credentials are stored securely in the device keychain.',
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),
              DbCredentialsForm(
                saveButtonLabel: 'Save & Continue',
                onSave: (creds) => _connect(context, creds),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext context, DbCredentials creds) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final uri = creds.buildUri();
    final connected = await MongoDbService().connect(uri);

    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (connected) {
      // Persist credentials
      await SecureStorageService().saveCredentials(creds);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
}
