import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_remote_image.dart';

class BreedFullscreenGallery extends StatefulWidget {
  const BreedFullscreenGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.label,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? label;

  @override
  State<BreedFullscreenGallery> createState() => _BreedFullscreenGalleryState();
}

class _BreedFullscreenGalleryState extends State<BreedFullscreenGallery> {
  late final PageController _pageController;
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

  Future<void> _showPage(int index) => _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: strings.closePhotoViewer,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          strings.photoPosition(_currentIndex + 1, widget.imageUrls.length),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: AppRemoteImage(
                  url: widget.imageUrls[index],
                  label: widget.label,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton.filledTonal(
                tooltip: strings.previousPhoto,
                onPressed: () => _showPage(_currentIndex - 1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          if (_currentIndex + 1 < widget.imageUrls.length)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton.filledTonal(
                tooltip: strings.nextPhoto,
                onPressed: () => _showPage(_currentIndex + 1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
