import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/language_menu.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive.dart';
import '../../domain/breed.dart';
import '../breeds_providers.dart';
import '../widgets/breed_card.dart';
import '../widgets/breed_state_message.dart';

class BreedsScreen extends ConsumerStatefulWidget {
  const BreedsScreen({super.key});

  @override
  ConsumerState<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends ConsumerState<BreedsScreen> {
  static const _initialVisibleCount = 8;
  static const _searchDelay = Duration(milliseconds: 350);

  Timer? _searchTimer;
  String _query = '';
  int _visibleCount = _initialVisibleCount;
  bool _showMinCharsHint = false;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    final normalized = value.trim().toLowerCase();
    final showHint = normalized.isNotEmpty && normalized.length < 2;
    if (_showMinCharsHint != showHint) {
      setState(() => _showMinCharsHint = showHint);
    }
    if (normalized.length < 2) {
      if (_query.isNotEmpty || _visibleCount != _initialVisibleCount) {
        setState(() {
          _query = '';
          _visibleCount = _initialVisibleCount;
        });
      }
      return;
    }
    _searchTimer = Timer(_searchDelay, () {
      if (!mounted) return;
      setState(() {
        _query = normalized;
        _visibleCount = _initialVisibleCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final breeds = ref.watch(breedsProvider);
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const LanguageMenu(),
          IconButton(
            tooltip: strings.refreshBreeds,
            onPressed: () => ref.invalidate(breedsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.pagePadding,
                    responsive.spacing(24),
                    responsive.pagePadding,
                    responsive.spacing(20),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.meetBreeds,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: responsive.spacing(8)),
                        Text(
                          strings.intro,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        SizedBox(height: responsive.spacing(24)),
                        TextField(
                          decoration: InputDecoration(
                            hintText: strings.searchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                        if (_showMinCharsHint) ...[
                          SizedBox(height: responsive.spacing(8)),
                          Text(
                            strings.searchMinimum,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ...breeds.when<List<Widget>>(
                  loading: () => [
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (error, stackTrace) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: BreedStateMessage(
                        icon: Icons.wifi_off_rounded,
                        title: strings.loadErrorTitle,
                        detail: strings.loadErrorDetail,
                        action: FilledButton(
                          onPressed: () => ref.invalidate(breedsProvider),
                          child: Text(strings.retry),
                        ),
                      ),
                    ),
                  ],
                  data: (items) => _breedSlivers(items, strings, responsive),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _breedSlivers(
    List<Breed> items,
    AppLocalizations strings,
    Responsive responsive,
  ) {
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: BreedStateMessage(
            icon: Icons.pets_outlined,
            title: strings.noBreedsTitle,
            detail: strings.noBreedsDetail,
          ),
        ),
      ];
    }
    final filtered = items.where((breed) {
      return breed.name.toLowerCase().contains(_query) ||
          (breed.origin?.toLowerCase().contains(_query) ?? false);
    }).toList();
    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: BreedStateMessage(
            icon: Icons.search_off_rounded,
            title: strings.noMatchesTitle,
            detail: strings.noMatchesDetail,
          ),
        ),
      ];
    }
    final visible = filtered.take(_visibleCount).toList();
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          responsive.pagePadding,
          responsive.spacing(4),
          responsive.pagePadding,
          responsive.spacing(16),
        ),
        sliver: SliverToBoxAdapter(
          // A Row cannot shrink these two labels: on narrow phones, or with a
          // large text scale, the counter would overflow. Wrap keeps both
          // readable, on one line while they fit and stacked when they do not.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: responsive.spacing(12),
            runSpacing: responsive.spacing(4),
            children: [
              Text(
                strings.breedsLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                strings.showingBreeds(visible.length, filtered.length),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final gap = responsive.spacing(16);
            final width = constraints.crossAxisExtent;
            final columns = ((width + gap) / (responsive.size(220) + gap))
                .floor()
                .clamp(1, 4);
            return SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
                mainAxisExtent: responsive.size(columns == 1 ? 320 : 280),
              ),
              itemCount: visible.length,
              itemBuilder: (context, index) => BreedCard(breed: visible[index]),
            );
          },
        ),
      ),
      if (visible.length < filtered.length)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            responsive.pagePadding,
            responsive.spacing(20),
            responsive.pagePadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: OutlinedButton(
                key: const Key('show-more-breeds'),
                onPressed: () =>
                    setState(() => _visibleCount += _initialVisibleCount),
                child: Text(strings.showMoreBreeds),
              ),
            ),
          ),
        ),
      SliverToBoxAdapter(child: SizedBox(height: responsive.spacing(32))),
    ];
  }
}
