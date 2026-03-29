import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/company.dart';
import '../../models/transaction.dart';
import '../../providers/company_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/validators.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _category;
  late DateTime _date;
  Company? _selectedCompany;

  List<String> _allCategories = [];

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
        text: widget.transaction?.amount.toStringAsFixed(2) ?? '');
    _descriptionController =
        TextEditingController(text: widget.transaction?.description ?? '');
    _category = widget.transaction?.category ?? AppConstants.defaultCategories.first;
    _date = widget.transaction?.date ?? DateTime.now();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final custom = await SecureStorageService().getCustomCategories();
    setState(() {
      _allCategories = [...AppConstants.defaultCategories, ...custom];
      if (!_allCategories.contains(_category)) {
        _allCategories.add(_category);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TransactionProvider>();
    final txn = Transaction(
      id: widget.transaction?.id,
      type: _type,
      amount: double.parse(_amountController.text.trim()),
      category: _category,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      companyId: _selectedCompany?.id,
      companyName: _selectedCompany?.name,
      date: _date,
      createdAt: widget.transaction?.createdAt,
    );

    if (isEditing) {
      await provider.update(txn);
    } else {
      await provider.add(txn);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final companies = context.watch<CompanyProvider>().activeCompanies;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type toggle
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: const Text('Income'),
                    icon: Icon(Icons.arrow_downward_rounded,
                        color: _type == TransactionType.income
                            ? Colors.white
                            : AppTheme.incomeGreen),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: const Text('Expense'),
                    icon: Icon(Icons.arrow_upward_rounded,
                        color: _type == TransactionType.expense
                            ? Colors.white
                            : AppTheme.expenseRed),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) => Validators.positiveNumber(v, 'Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                value: _allCategories.contains(_category) ? _category : null,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _allCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select a category' : null,
              ),
              const SizedBox(height: 20),

              // Company link (for income)
              if (_type == TransactionType.income && companies.isNotEmpty) ...[
                DropdownButtonFormField<Company>(
                  value: _selectedCompany,
                  decoration: const InputDecoration(
                    labelText: 'Company (optional)',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<Company>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...companies.map(
                      (c) =>
                          DropdownMenuItem(value: c, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedCompany = v),
                ),
                const SizedBox(height: 20),
              ],

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _save,
                child:
                    Text(isEditing ? 'Update Transaction' : 'Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
