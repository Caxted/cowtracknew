import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BatchEntryWidget extends StatefulWidget {
  final Function(double, String) onBatchSaved;

  const BatchEntryWidget({
    super.key,
    required this.onBatchSaved,
  });

  @override
  State<BatchEntryWidget> createState() => _BatchEntryWidgetState();
}

class _BatchEntryWidgetState extends State<BatchEntryWidget> {
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  String _selectedUnit = 'L';
  int _estimatedCows = 0;
  double _averagePerCow = 0.0;

  final List<String> _units = ['L', 'Gallons'];
  final List<double> _quickAmounts = [50, 100, 150, 200, 250, 300];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateDistribution);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _calculateDistribution() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity > 0) {
      // Estimate based on average production per cow (25L)
      final avgProduction =
          _selectedUnit == 'L' ? 25.0 : 6.6; // 6.6 gallons ≈ 25L
      setState(() {
        _estimatedCows = (quantity / avgProduction).round();
        _averagePerCow = _estimatedCows > 0 ? quantity / _estimatedCows : 0.0;
      });
    } else {
      setState(() {
        _estimatedCows = 0;
        _averagePerCow = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          _buildTotalQuantityInput(),
          SizedBox(height: 3.h),
          _buildQuickAmountButtons(),
          SizedBox(height: 3.h),
          _buildDistributionInfo(),
          SizedBox(height: 3.h),
          _buildQualityRating(),
          SizedBox(height: 3.h),
          _buildNotesSection(),
          SizedBox(height: 4.h),
          _buildSaveButton(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildTotalQuantityInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Milk Production',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _quantityController,
                  focusNode: _quantityFocusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.dividerColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.dividerColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.dividerColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.dividerColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(
                        unit,
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                    _calculateDistribution();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Entry',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _quickAmounts.map((amount) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _quantityController.text = amount.toString();
                  _calculateDistribution();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$amount $_selectedUnit',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistributionInfo() {
    if (_estimatedCows == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calculate',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Distribution Estimate',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Cows:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              Text(
                '$_estimatedCows cows',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average per cow:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              Text(
                '${_averagePerCow.toStringAsFixed(1)} $_selectedUnit',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRating() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milk Quality Rating',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Quality rating functionality can be added here
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: 'star',
                      color: index < 4
                          ? Colors.amber
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                      size: 28,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Notes',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Add notes about production conditions, weather, feed changes, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2.0,
                ),
              ),
              contentPadding: EdgeInsets.all(3.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final isValid = quantity > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? () => _saveBatchEntry() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
          foregroundColor: isValid
              ? AppTheme.lightTheme.colorScheme.onPrimary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'save',
              color: isValid
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Save Batch Entry',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isValid
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBatchEntry() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    widget.onBatchSaved(quantity, _selectedUnit);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Batch entry saved: $quantity $_selectedUnit'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Clear form
    _quantityController.clear();
    setState(() {
      _estimatedCows = 0;
      _averagePerCow = 0.0;
    });
  }
}
