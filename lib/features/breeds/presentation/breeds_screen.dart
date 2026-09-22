import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/language_menu.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../domain/breed.dart';
import 'breed_image.dart';
import 'breeds_providers.dart';

class BreedsScreen extends ConsumerStatefulWidget {
  const BreedsScreen({super.key});

  @override
  ConsumerState<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends ConsumerState<BreedsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final breeds = ref.watch(breedsProvider);
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
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
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: responsive.spacing(24)),
                        TextField(
                          decoration: InputDecoration(
                            hintText: strings.searchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                          onChanged: (value) => setState(
                            () => query = value.trim().toLowerCase(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                breeds.when(
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Message(
                      icon: Icons.wifi_off_rounded,
                      title: strings.loadErrorTitle,
                      detail: strings.loadErrorDetail,
                      action: FilledButton(
                        onPressed: () => ref.invalidate(breedsProvider),
                        child: Text(strings.retry),
                      ),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _Message(
                          icon: Icons.pets_outlined,
                          title: strings.noBreedsTitle,
                          detail: strings.noBreedsDetail,
                        ),
                      );
                    }
                    final filtered = items
                        .where(
                          (breed) => breed.name.toLowerCase().contains(query),
                        )
                        .toList();
                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _Message(
                          icon: Icons.search_off_rounded,
                          title: strings.noMatchesTitle,
                          detail: strings.noMatchesDetail,
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        responsive.pagePadding,
                        0,
                        responsive.pagePadding,
                        responsive.spacing(24),
                      ),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final gap = responsive.spacing(16);
                          final width = constraints.crossAxisExtent;
                          final columns =
                              ((width + gap) / (responsive.size(220) + gap))
                                  .floor()
                                  .clamp(1, 4);
                          return SliverGrid.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: gap,
                                  mainAxisSpacing: gap,
                                  mainAxisExtent: responsive.size(260),
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _BreedCard(breed: filtered[index]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreedCard extends StatelessWidget {
  const _BreedCard({required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.radius(18)),
        side: const BorderSide(color: Color(0xFFEDE3D9)),
      ),
      child: InkWell(
        onTap: () => context.go('/breeds/${breed.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: BreedImage(url: breed.imageUrl)),
            Padding(
              padding: EdgeInsets.all(responsive.spacing(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (breed.origin != null) ...[
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      breed.origin!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsive.icon(48),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: responsive.spacing(4)),
            Text(detail, textAlign: TextAlign.center),
            if (action != null) ...[
              SizedBox(height: responsive.spacing(16)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
