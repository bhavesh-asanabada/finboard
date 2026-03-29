import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../models/db_credentials.dart';
import '../services/mongodb_service.dart';
import '../services/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';
  bool _hasError = false;
  String? _errorDetail;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final storage = SecureStorageService();
      final DbCredentials? creds = await storage.getCredentials();

      if (creds == null || !creds.isComplete) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
        return;
      }

      setState(() => _status = 'Connecting to database...');

      final uri = creds.buildUri();
      final connected = await MongoDbService().connect(uri);

      if (!mounted) return;

      if (connected) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() {
          _hasError = true;
          _errorDetail = MongoDbService().lastError;
          _status = 'Connection failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorDetail = e.toString();
        _status = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _hasError ? Icons.error_outline : Icons.account_balance_wallet,
                size: 64,
                color: _hasError
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'FinBoard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (!_hasError)
                const CircularProgressIndicator()
              else
                const Icon(Icons.cloud_off, color: Colors.red, size: 32),
              const SizedBox(height: 16),
              Text(
                _status,
                style: TextStyle(
                  color: _hasError ? Colors.red : Colors.grey[600],
                ),
              ),
              if (_errorDetail != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorDetail!,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (_hasError) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorDetail = null;
                          _status = 'Retrying...';
                        });
                        _init();
                      },
                      child: const Text('Retry'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.setup),
                      child: const Text('Reconfigure'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
