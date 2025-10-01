import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CowPhotoGalleryWidget extends StatefulWidget {
  final List<String> photos;
  final String cowName;

  const CowPhotoGalleryWidget({
    super.key,
    required this.photos,
    required this.cowName,
  });

  @override
  State<CowPhotoGalleryWidget> createState() => _CowPhotoGalleryWidgetState();
}

class _CowPhotoGalleryWidgetState extends State<CowPhotoGalleryWidget> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          photos: widget.photos,
          initialIndex: _currentPhotoIndex,
          cowName: widget.cowName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return _buildEmptyPhotoState();
    }

    return Container(
      height: 35.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Photo PageView
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPhotoIndex = index;
                });
              },
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _showFullScreenGallery,
                  child: CustomImageWidget(
                    imageUrl: widget.photos[index],
                    width: double.infinity,
                    height: 35.h,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          // Photo indicators
          if (widget.photos.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.photos.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPhotoIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPhotoIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Expand button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: _showFullScreenGallery,
                child: CustomIconWidget(
                  iconName: 'fullscreen',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Photo counter
          if (widget.photos.length > 1)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${widget.photos.length}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoState() {
    return Container(
      height: 35.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'photo_camera',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.4),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No photos available',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap to add photos',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String cowName;

  const _FullScreenGallery({
    required this.photos,
    required this.initialIndex,
    required this.cowName,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.cowName} Photos',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
            icon: CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: CustomImageWidget(
                    imageUrl: widget.photos[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Photo counter overlay
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} of ${widget.photos.length}',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
