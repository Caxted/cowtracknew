import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoAttachmentWidget extends StatefulWidget {
  final List<XFile> attachedPhotos;
  final Function(List<XFile>) onPhotosChanged;

  const PhotoAttachmentWidget({
    super.key,
    required this.attachedPhotos,
    required this.onPhotosChanged,
  });

  @override
  State<PhotoAttachmentWidget> createState() => _PhotoAttachmentWidgetState();
}

class _PhotoAttachmentWidgetState extends State<PhotoAttachmentWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      if (!await _requestCameraPermission()) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Ignore focus mode errors
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        // Ignore flash mode errors on unsupported devices
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedPhotos = List<XFile>.from(widget.attachedPhotos)..add(photo);
      widget.onPhotosChanged(updatedPhotos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final updatedPhotos = List<XFile>.from(widget.attachedPhotos)
          ..add(photo);
        widget.onPhotosChanged(updatedPhotos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick photo from gallery')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    final updatedPhotos = List<XFile>.from(widget.attachedPhotos)
      ..removeAt(index);
    widget.onPhotosChanged(updatedPhotos);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Add Photo',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoOption(
                    icon: 'camera_alt',
                    title: 'Camera',
                    subtitle: 'Take a new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _capturePhoto();
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildPhotoOption(
                    icon: 'photo_library',
                    title: 'Gallery',
                    subtitle: 'Choose from gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
                  iconName: 'photo_camera',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Photo Attachments',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.attachedPhotos.length}/5',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
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
                // Camera preview (if available and no photos)
                if (_isCameraInitialized && widget.attachedPhotos.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 25.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_cameraController!),
                    ),
                  ),

                // Photo grid
                if (widget.attachedPhotos.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 1.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: widget.attachedPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = widget.attachedPhotos[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.lightTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      photo.path,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(photo.path),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 1.w,
                            right: 1.w,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'close',
                                    color:
                                        AppTheme.lightTheme.colorScheme.onError,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                SizedBox(height: 2.h),

                // Add photo button
                if (widget.attachedPhotos.length < 5)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showPhotoOptions,
                      icon: CustomIconWidget(
                        iconName: 'add_a_photo',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        widget.attachedPhotos.isEmpty
                            ? 'Add Receipt or Delivery Photo'
                            : 'Add Another Photo',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),

                // Helper text
                if (widget.attachedPhotos.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'Attach photos of receipts, delivery confirmations, or quality certificates',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
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
