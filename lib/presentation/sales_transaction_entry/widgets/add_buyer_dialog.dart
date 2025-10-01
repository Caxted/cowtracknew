import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddBuyerDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onBuyerAdded;

  const AddBuyerDialog({
    super.key,
    required this.onBuyerAdded,
  });

  @override
  State<AddBuyerDialog> createState() => _AddBuyerDialogState();
}

class _AddBuyerDialogState extends State<AddBuyerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedPaymentTerms = 'Cash';
  String _selectedUnit = 'gallons';

  final List<String> _paymentTermsOptions = [
    'Cash',
    'Cash on Delivery',
    'Net 15',
    'Net 30',
    'Net 60',
  ];

  final List<String> _unitOptions = [
    'gallons',
    'liters',
    'quarts',
    'pints',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveBuyer() {
    if (_formKey.currentState!.validate()) {
      final newBuyer = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "name": _nameController.text.trim(),
        "contact": _contactController.text.trim(),
        "email": _emailController.text.trim(),
        "paymentTerms": _selectedPaymentTerms,
        "lastPurchase": DateTime.now().toString().substring(0, 10),
        "totalPurchases": 0,
        "preferredUnit": _selectedUnit,
      };

      widget.onBuyerAdded(newBuyer);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 80.h,
          maxWidth: 90.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person_add',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Add New Buyer',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company/Person Name
                      Text(
                        'Buyer Name *',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter company or person name',
                          prefixIcon: Icon(
                            Icons.business,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter buyer name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Contact Number
                      Text(
                        'Contact Number *',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d\s\-\+\(\)]')),
                        ],
                        decoration: InputDecoration(
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter contact number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Email Address
                      Text(
                        'Email Address',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'buyer@example.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Payment Terms
                      Text(
                        'Payment Terms',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentTerms,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.payment,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        items: _paymentTermsOptions.map((terms) {
                          return DropdownMenuItem(
                            value: terms,
                            child: Text(terms),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentTerms = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Preferred Unit
                      Text(
                        'Preferred Unit',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.straighten,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        items: _unitOptions.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedUnit = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveBuyer,
                      child: const Text('Add Buyer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
