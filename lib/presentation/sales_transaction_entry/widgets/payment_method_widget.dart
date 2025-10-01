import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const PaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  final List<Map<String, dynamic>> paymentMethods = const [
    {
      'id': 'cash',
      'name': 'Cash',
      'icon': 'payments',
      'description': 'Immediate cash payment',
    },
    {
      'id': 'check',
      'name': 'Check',
      'icon': 'receipt',
      'description': 'Bank check payment',
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'icon': 'account_balance',
      'description': 'Direct bank transfer',
    },
    {
      'id': 'credit',
      'name': 'Credit',
      'icon': 'credit_card',
      'description': 'Payment on credit terms',
    },
  ];

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
                  iconName: 'payment',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Payment Method',
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
                // Payment method grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    final isSelected = selectedMethod == method['id'];

                    return GestureDetector(
                      onTap: () => onMethodChanged(method['id'] as String),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: method['icon'] as String,
                                    color: isSelected
                                        ? AppTheme
                                            .lightTheme.colorScheme.onPrimary
                                        : AppTheme
                                            .lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      method['name'] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        color: isSelected
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.h),

                // Selected method description
                if (selectedMethod.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info_outline',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            paymentMethods.firstWhere(
                              (method) => method['id'] == selectedMethod,
                              orElse: () => paymentMethods.first,
                            )['description'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                            ),
                          ),
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
