import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_reference.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/section_title.dart';
import '../../catalog/widgets/breed_card.dart';

/// Horizontal suggestion row with the remaining breeds.
///
/// The row shows a bounded set and reports how many breeds it leaves out, so
/// browsing stays local while the full catalog stays one action away. The
/// reference map feeds the same card used by the catalog.
class RelatedBreedsSection extends StatefulWidget {
  const RelatedBreedsSection({
    super.key,
    required this.breeds,
    required this.references,
    required this.onBreedSelected,
    required this.onShowAll,
  });

  /// Breeds to suggest, already excluding the one on screen.
  final List<Breed> breeds;

  /// Traits of the bundled dataset per breed ID, the same map the catalog
  /// cards read.
  final Map<String, BreedReference> references;

  final ValueChanged<Breed> onBreedSelected;
  final VoidCallback onShowAll;

  static const int visibleCount = 6;

  @override
  State<RelatedBreedsSection> createState() => _RelatedBreedsSectionState();
}

class _RelatedBreedsSectionState extends State<RelatedBreedsSection> {
  final ScrollController _scrollController = ScrollController();
  bool _canShowPrevious = false;
  bool _canShowNext = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateNavigation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavigation());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateNavigation)
      ..dispose();
    super.dispose();
  }

  void _updateNavigation() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canShowPrevious = position.pixels > 0;
    final canShowNext = position.pixels < position.maxScrollExtent;
    if (_canShowPrevious == canShowPrevious && _canShowNext == canShowNext) {
      return;
    }
    setState(() {
      _canShowPrevious = canShowPrevious;
      _canShowNext = canShowNext;
    });
  }

  void _scrollByViewport(int direction) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (position.pixels + direction * position.viewportDimension)
        .clamp(0.0, position.maxScrollExtent)
        .toDouble();
    unawaited(
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.breeds.isEmpty) return const SizedBox.shrink();
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final visible = widget.breeds
        .take(RelatedBreedsSection.visibleCount)
        .toList();
    final remaining = widget.breeds.length - visible.length;
    final showDesktopControls = responsive.isDesktop && visible.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(strings.relatedBreeds)),
            if (remaining > 0)
              TextButton(
                onPressed: widget.onShowAll,
                child: Text(strings.moreBreeds(remaining)),
              ),
          ],
        ),
        SizedBox(height: responsive.spacing(8)),
        SizedBox(
          height: responsive.size(240),
          child: Stack(
            children: [
              ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: responsive.spacing(12)),
                itemBuilder: (context, index) {
                  final breed = visible[index];
                  return SizedBox(
                    width: responsive.size(180),
                    child: BreedCard(
                      breed: breed,
                      intelligence: widget.references[breed.id]?.intelligence,
                      onTap: () => widget.onBreedSelected(breed),
                    ),
                  );
                },
              ),
              if (showDesktopControls) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    key: const Key('related-breeds-previous'),
                    tooltip: strings.previousRelatedBreeds,
                    onPressed: _canShowPrevious
                        ? () => _scrollByViewport(-1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filledTonal(
                    key: const Key('related-breeds-next'),
                    tooltip: strings.nextRelatedBreeds,
                    onPressed: _canShowNext ? () => _scrollByViewport(1) : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
