import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MilkInputOverlayWidget extends StatefulWidget {
  final Map<String, dynamic> cowData;
  final Function(double, String) onSaved;
  final VoidCallback onCancel;

  const MilkInputOverlayWidget({
    super.key,
    required this.cowData,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<MilkInputOverlayWidget> createState() => _MilkInputOverlayWidgetState();
}

class _MilkInputOverlayWidgetState extends State<MilkInputOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'L';
  String _selectedSession = 'Morning';
  int _qualityRating = 4;

  final List<String> _units = ['L', 'Gallons'];
  final List<String> _sessions = ['Morning', 'Evening'];
  final List<double> _quickAmounts = [15, 20, 25, 30, 35];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Pre-fill with previous production amount
    final lastProduction = widget.cowData["lastProduction"] as double;
    _quantityController.text = lastProduction.toString();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 90.w,
                  constraints: BoxConstraints(maxHeight: 80.h),
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildCowInfo(),
                        _buildQuantityInput(),
                        _buildQuickAmounts(),
                        _buildSessionSelector(),
                        _buildQualityRating(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Record Milk Production',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleCancel,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCowInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageWidget(
                imageUrl: widget.cowData["image"] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cowData["name"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${widget.cowData["id"]} • ${widget.cowData["breed"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Previous: ${widget.cowData["lastProduction"]}${widget.cowData["unit"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle:
                    AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color:
                        AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color:
                        AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 3.h),
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
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color:
                        AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color:
                        AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
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
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                      '$amount',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildSessionSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: _sessions.map((session) {
                final isSelected = _selectedSession == session;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSession = session;
                        });
                        HapticFeedback.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRating() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Rating',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _qualityRating = starIndex;
                    });
                    HapticFeedback.selectionClick();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName:
                          starIndex <= _qualityRating ? 'star' : 'star_border',
                      color: starIndex <= _qualityRating
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

  Widget _buildActionButtons() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final isValid = quantity > 0;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isValid ? _handleSave : null,
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
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Save Entry',
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
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      widget.onCancel();
    });
  }

  void _handleSave() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    HapticFeedback.mediumImpact();

    _animationController.reverse().then((_) {
      widget.onSaved(quantity, _selectedUnit);
    });
  }
}
