import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionDetailsWidget extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String invoiceNumber;
  final String notes;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;
  final Function(String) onInvoiceNumberChanged;
  final Function(String) onNotesChanged;

  const TransactionDetailsWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.invoiceNumber,
    required this.notes,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onInvoiceNumberChanged,
    required this.onNotesChanged,
  });

  @override
  State<TransactionDetailsWidget> createState() =>
      _TransactionDetailsWidgetState();
}

class _TransactionDetailsWidgetState extends State<TransactionDetailsWidget> {
  late TextEditingController _invoiceController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _invoiceController = TextEditingController(text: widget.invoiceNumber);
    _notesController = TextEditingController(text: widget.notes);
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
                  iconName: 'event_note',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Transaction Details',
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
                // Date and Time Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.lightTheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'calendar_today',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      _formatDate(widget.selectedDate),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.lightTheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'access_time',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      _formatTime(widget.selectedTime),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Invoice Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Invoice Number',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _generateInvoiceNumber,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            minimumSize: Size.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'refresh',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Generate',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _invoiceController,
                      decoration: InputDecoration(
                        hintText: 'Enter invoice number',
                        prefixIcon: Icon(
                          Icons.receipt_long,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      onChanged: widget.onInvoiceNumberChanged,
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Notes Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes (Optional)',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Add delivery details, quality specifications, or special terms...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Icon(
                            Icons.note_add_outlined,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      onChanged: widget.onNotesChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedTime) {
      widget.onTimeChanged(picked);
    }
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    final invoiceNumber =
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';

    _invoiceController.text = invoiceNumber;
    widget.onInvoiceNumberChanged(invoiceNumber);

    HapticFeedback.lightImpact();
  }
}
