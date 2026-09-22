import 'package:flutter/material.dart';

import '../../../../shared/responsive.dart';
import '../../domain/breed.dart';
import 'breed_image.dart';
import 'breed_information.dart';

class BreedDetailContent extends StatelessWidget {
  const BreedDetailContent({super.key, required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    responsive.pagePadding,
                    responsive.spacing(16),
                    responsive.pagePadding,
                    responsive.spacing(40),
                  ),
                  children: [
                    _photo(
                      responsive,
                      height: responsive.hp(38).clamp(200.0, 360.0),
                    ),
                    SizedBox(height: responsive.spacing(26)),
                    BreedInformation(breed: breed),
                  ],
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                  vertical: responsive.spacing(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _photo(responsive)),
                    SizedBox(width: responsive.spacing(32)),
                    Expanded(
                      flex: 6,
                      child: ListView(
                        padding: EdgeInsets.only(
                          bottom: responsive.spacing(24),
                        ),
                        children: [BreedInformation(breed: breed)],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _photo(Responsive responsive, {double? height}) => ClipRRect(
    borderRadius: BorderRadius.circular(responsive.radius(16)),
    child: height == null
        ? BreedImage(url: breed.imageUrl)
        : SizedBox(
            height: height,
            child: BreedImage(url: breed.imageUrl),
          ),
  );
}
