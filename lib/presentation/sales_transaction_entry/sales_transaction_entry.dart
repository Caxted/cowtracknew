import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/add_buyer_dialog.dart';
import './widgets/buyer_selection_widget.dart';
import './widgets/invoice_preview_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/photo_attachment_widget.dart';
import './widgets/quantity_price_widget.dart';
import './widgets/transaction_details_widget.dart';

class SalesTransactionEntry extends StatefulWidget {
  const SalesTransactionEntry({super.key});

  @override
  State<SalesTransactionEntry> createState() => _SalesTransactionEntryState();
}

class _SalesTransactionEntryState extends State<SalesTransactionEntry> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form Data
  Map<String, dynamic>? _selectedBuyer;
  double _quantity = 0.0;
  double _pricePerUnit = 0.0;
  String _selectedUnit = 'gallons';
  String _selectedCurrency = 'USD';
  String _selectedPaymentMethod = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _invoiceNumber = '';
  String _notes = '';
  List<XFile> _attachedPhotos = [];

  // UI State
  bool _isLoading = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _generateInitialInvoiceNumber();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateInitialInvoiceNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    _invoiceNumber =
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }

  bool get _isFormValid {
    return _selectedBuyer != null &&
        _quantity > 0 &&
        _pricePerUnit > 0 &&
        _selectedPaymentMethod.isNotEmpty &&
        _invoiceNumber.isNotEmpty;
  }

  double get _totalAmount => _quantity * _pricePerUnit;

  String get _currencySymbol {
    final currencies = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'CAD': 'C\$',
    };
    return currencies[_selectedCurrency] ?? '\$';
  }

  void _onBuyerSelected(Map<String, dynamic> buyer) {
    setState(() {
      _selectedBuyer = buyer.isEmpty ? null : buyer;
      if (buyer.isNotEmpty) {
        // Auto-populate preferred unit if available
        if (buyer['preferredUnit'] != null) {
          _selectedUnit = buyer['preferredUnit'] as String;
        }
      }
    });
  }

  void _onAddNewBuyer() {
    showDialog(
      context: context,
      builder: (context) => AddBuyerDialog(
        onBuyerAdded: (newBuyer) {
          setState(() {
            _selectedBuyer = newBuyer;
            _selectedUnit = newBuyer['preferredUnit'] as String;
          });
        },
      ),
    );
  }

  void _onQuantityChanged(double quantity) {
    setState(() {
      _quantity = quantity;
    });
  }

  void _onPriceChanged(double price) {
    setState(() {
      _pricePerUnit = price;
    });
  }

  void _onUnitChanged(String unit) {
    setState(() {
      _selectedUnit = unit;
    });
  }

  void _onCurrencyChanged(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _onPaymentMethodChanged(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onTimeChanged(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _onInvoiceNumberChanged(String invoiceNumber) {
    setState(() {
      _invoiceNumber = invoiceNumber;
    });
  }

  void _onNotesChanged(String notes) {
    setState(() {
      _notes = notes;
    });
  }

  void _onPhotosChanged(List<XFile> photos) {
    setState(() {
      _attachedPhotos = photos;
    });
  }

  void _togglePreview() {
    setState(() {
      _showPreview = !_showPreview;
    });

    if (_showPreview) {
      // Scroll to bottom to show preview
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        HapticFeedback.lightImpact();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 48,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Transaction Saved!',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Invoice $_invoiceNumber has been created successfully.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_currencySymbol${_totalAmount.toStringAsFixed(2)}',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm();
                },
                child: const Text('Create Another'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/dashboard-home');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Failed to save transaction. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedBuyer = null;
      _quantity = 0.0;
      _pricePerUnit = 0.0;
      _selectedUnit = 'gallons';
      _selectedCurrency = 'USD';
      _selectedPaymentMethod = '';
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _notes = '';
      _attachedPhotos = [];
      _showPreview = false;
      _generateInitialInvoiceNumber();
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _cancelTransaction() {
    if (_selectedBuyer != null ||
        _quantity > 0 ||
        _pricePerUnit > 0 ||
        _notes.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to cancel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Sales Transaction',
        leading: IconButton(
          onPressed: _cancelTransaction,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
          tooltip: 'Cancel',
        ),
        actions: [
          TextButton(
            onPressed: _isFormValid ? _saveTransaction : null,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _isFormValid ? 1.0 : 0.6,
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    _isFormValid ? 'Complete' : 'In Progress',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Buyer Selection
                    BuyerSelectionWidget(
                      selectedBuyer: _selectedBuyer,
                      onBuyerSelected: _onBuyerSelected,
                      onAddNewBuyer: _onAddNewBuyer,
                    ),
                    SizedBox(height: 3.h),

                    // Quantity & Pricing
                    QuantityPriceWidget(
                      quantity: _quantity,
                      pricePerUnit: _pricePerUnit,
                      selectedUnit: _selectedUnit,
                      selectedCurrency: _selectedCurrency,
                      onQuantityChanged: _onQuantityChanged,
                      onPriceChanged: _onPriceChanged,
                      onUnitChanged: _onUnitChanged,
                      onCurrencyChanged: _onCurrencyChanged,
                    ),
                    SizedBox(height: 3.h),

                    // Payment Method
                    PaymentMethodWidget(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodChanged: _onPaymentMethodChanged,
                    ),
                    SizedBox(height: 3.h),

                    // Transaction Details
                    TransactionDetailsWidget(
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      invoiceNumber: _invoiceNumber,
                      notes: _notes,
                      onDateChanged: _onDateChanged,
                      onTimeChanged: _onTimeChanged,
                      onInvoiceNumberChanged: _onInvoiceNumberChanged,
                      onNotesChanged: _onNotesChanged,
                    ),
                    SizedBox(height: 3.h),

                    // Photo Attachments
                    PhotoAttachmentWidget(
                      attachedPhotos: _attachedPhotos,
                      onPhotosChanged: _onPhotosChanged,
                    ),
                    SizedBox(height: 3.h),

                    // Preview Toggle Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isFormValid ? _togglePreview : null,
                        icon: CustomIconWidget(
                          iconName:
                              _showPreview ? 'visibility_off' : 'visibility',
                          color: _isFormValid
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                          size: 20,
                        ),
                        label: Text(
                          _showPreview ? 'Hide Preview' : 'Preview Invoice',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),

                    // Invoice Preview
                    if (_showPreview) ...[
                      SizedBox(height: 3.h),
                      InvoicePreviewWidget(
                        selectedBuyer: _selectedBuyer,
                        quantity: _quantity,
                        selectedUnit: _selectedUnit,
                        pricePerUnit: _pricePerUnit,
                        selectedCurrency: _selectedCurrency,
                        selectedPaymentMethod: _selectedPaymentMethod,
                        selectedDate: _selectedDate,
                        invoiceNumber: _invoiceNumber,
                        notes: _notes,
                      ),
                    ],

                    SizedBox(height: 10.h), // Bottom padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isFormValid
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _saveTransaction,
              icon: _isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'save',
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      size: 20,
                    ),
              label: Text(
                _isLoading ? 'Saving...' : 'Save Transaction',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex:
            CustomBottomBar.getCurrentIndex('/sales-transaction-entry'),
        onTap: (index) {
          // Handle navigation if needed
        },
      ),
    );
  }
}
