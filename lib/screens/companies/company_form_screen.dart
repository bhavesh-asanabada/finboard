import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/company.dart';
import '../../providers/company_provider.dart';
import '../../utils/validators.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _payRateController;
  late final TextEditingController _notesController;
  late PayType _payType;
  late String _currency;

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _payRateController = TextEditingController(
        text: widget.company?.payRate.toStringAsFixed(2) ?? '');
    _notesController =
        TextEditingController(text: widget.company?.notes ?? '');
    _payType = widget.company?.payType ?? PayType.hourly;
    _currency = widget.company?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _payRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CompanyProvider>();
    final company = Company(
      id: widget.company?.id,
      name: _nameController.text.trim(),
      payType: _payType,
      payRate: double.parse(_payRateController.text.trim()),
      currency: _currency,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isActive: widget.company?.isActive ?? true,
      createdAt: widget.company?.createdAt,
    );

    if (isEditing) {
      await provider.update(company);
    } else {
      await provider.add(company);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Company' : 'Add Company'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) => Validators.required(v, 'Company name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Pay type toggle
              Text('Pay Type',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<PayType>(
                segments: const [
                  ButtonSegment(
                    value: PayType.hourly,
                    label: Text('Hourly'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                  ButtonSegment(
                    value: PayType.monthly,
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_payType},
                onSelectionChanged: (v) => setState(() => _payType = v.first),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _payRateController,
                decoration: InputDecoration(
                  labelText: 'Pay Rate *',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: _payType == PayType.hourly ? '/hr' : '/mo',
                ),
                validator: (v) => Validators.positiveNumber(v, 'Pay rate'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),

              // Currency
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                  DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                  DropdownMenuItem(value: 'CAD', child: Text('CAD (C\$)')),
                  DropdownMenuItem(value: 'AUD', child: Text('AUD (A\$)')),
                ],
                onChanged: (v) => setState(() => _currency = v ?? 'USD'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Update Company' : 'Add Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
