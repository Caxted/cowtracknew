import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuantityPriceWidget extends StatefulWidget {
  final double quantity;
  final double pricePerUnit;
  final String selectedUnit;
  final String selectedCurrency;
  final Function(double) onQuantityChanged;
  final Function(double) onPriceChanged;
  final Function(String) onUnitChanged;
  final Function(String) onCurrencyChanged;

  const QuantityPriceWidget({
    super.key,
    required this.quantity,
    required this.pricePerUnit,
    required this.selectedUnit,
    required this.selectedCurrency,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onUnitChanged,
    required this.onCurrencyChanged,
  });

  @override
  State<QuantityPriceWidget> createState() => _QuantityPriceWidgetState();
}

class _QuantityPriceWidgetState extends State<QuantityPriceWidget> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  final List<String> units = ['gallons', 'liters', 'quarts', 'pints'];
  final List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$'},
    {'code': 'EUR', 'symbol': '€'},
    {'code': 'GBP', 'symbol': '£'},
    {'code': 'CAD', 'symbol': 'C\$'},
  ];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.quantity > 0 ? widget.quantity.toString() : '',
    );
    _priceController = TextEditingController(
      text:
          widget.pricePerUnit > 0 ? widget.pricePerUnit.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get totalAmount => widget.quantity * widget.pricePerUnit;

  String get currencySymbol {
    final currency = currencies.firstWhere(
      (c) => c['code'] == widget.selectedCurrency,
      orElse: () => currencies.first,
    );
    return currency['symbol'] ?? '\$';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calculate',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Quantity & Pricing',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.lightTheme.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Quantity Input
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: Icon(
                                Icons.water_drop_outlined,
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              final quantity = double.tryParse(value) ?? 0.0;
                              widget.onQuantityChanged(quantity);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: widget.selectedUnit,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            items: units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  unit,
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                widget.onUnitChanged(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Price Input
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price per ${widget.selectedUnit.substring(0, widget.selectedUnit.length - 1)}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: Container(
                                width: 12.w,
                                alignment: Alignment.center,
                                child: Text(
                                  currencySymbol,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              final price = double.tryParse(value) ?? 0.0;
                              widget.onPriceChanged(price);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currency',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          DropdownButtonFormField<String>(
                            value: widget.selectedCurrency,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            items: currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency['code'],
                                child: Row(
                                  children: [
                                    Text(
                                      currency['symbol']!,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      currency['code']!,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                widget.onCurrencyChanged(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Total Amount Display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$currencySymbol${totalAmount.toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.quantity.toStringAsFixed(1)} ${widget.selectedUnit}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            ' × ',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            '$currencySymbol${widget.pricePerUnit.toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
