import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BuyerSelectionWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedBuyer;
  final Function(Map<String, dynamic>) onBuyerSelected;
  final VoidCallback onAddNewBuyer;

  const BuyerSelectionWidget({
    super.key,
    this.selectedBuyer,
    required this.onBuyerSelected,
    required this.onAddNewBuyer,
  });

  @override
  State<BuyerSelectionWidget> createState() => _BuyerSelectionWidgetState();
}

class _BuyerSelectionWidgetState extends State<BuyerSelectionWidget> {
  final List<Map<String, dynamic>> recentBuyers = [
    {
      "id": 1,
      "name": "Green Valley Dairy Co.",
      "contact": "+1 (555) 123-4567",
      "email": "orders@greenvalleydairy.com",
      "paymentTerms": "Net 30",
      "lastPurchase": "2025-09-10",
      "totalPurchases": 15,
      "preferredUnit": "gallons",
    },
    {
      "id": 2,
      "name": "Fresh Farm Markets",
      "contact": "+1 (555) 987-6543",
      "email": "procurement@freshfarmmarkets.com",
      "paymentTerms": "Cash on Delivery",
      "lastPurchase": "2025-09-08",
      "totalPurchases": 8,
      "preferredUnit": "liters",
    },
    {
      "id": 3,
      "name": "Mountain View Creamery",
      "contact": "+1 (555) 456-7890",
      "email": "buying@mountainviewcreamery.com",
      "paymentTerms": "Net 15",
      "lastPurchase": "2025-09-05",
      "totalPurchases": 22,
      "preferredUnit": "gallons",
    },
    {
      "id": 4,
      "name": "Local Grocery Chain",
      "contact": "+1 (555) 321-0987",
      "email": "dairy@localgrocery.com",
      "paymentTerms": "Cash",
      "lastPurchase": "2025-09-12",
      "totalPurchases": 5,
      "preferredUnit": "liters",
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
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Select Buyer',
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
          widget.selectedBuyer != null
              ? _buildSelectedBuyer()
              : _buildBuyerDropdown(),
        ],
      ),
    );
  }

  Widget _buildSelectedBuyer() {
    final buyer = widget.selectedBuyer!;
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buyer["name"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      buyer["contact"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => widget.onBuyerSelected({}),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                child: Text(
                  'Change',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Terms',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        buyer["paymentTerms"] as String,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 4.h,
                  color: AppTheme.lightTheme.dividerColor,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Orders',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${buyer["totalPurchases"]} orders',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
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

  Widget _buildBuyerDropdown() {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentBuyers.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) {
            final buyer = recentBuyers[index];
            return InkWell(
              onTap: () => widget.onBuyerSelected(buyer),
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (buyer["name"] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer["name"] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            buyer["contact"] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${buyer["totalPurchases"]} orders',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          buyer["paymentTerms"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Divider(
          height: 1,
          color: AppTheme.lightTheme.dividerColor,
        ),
        InkWell(
          onTap: widget.onAddNewBuyer,
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Add New Buyer',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
