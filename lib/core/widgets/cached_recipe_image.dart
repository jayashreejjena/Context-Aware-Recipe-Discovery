import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_shimmer.dart';

class CachedRecipeImage extends StatelessWidget {
  const CachedRecipeImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 28,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = _ImageFallback(iconSize: iconSize);

    if (imageUrl.trim().isEmpty) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 90),
      memCacheWidth: _cacheExtent(width),
      memCacheHeight: _cacheExtent(height),
      placeholder: (context, url) => SizedBox(
        width: width,
        height: height,
        child: const _ImagePlaceholder(),
      ),
      errorWidget: (context, url, error) =>
          SizedBox(width: width, height: height, child: fallback),
    );
  }

  int? _cacheExtent(double? logicalPixels) {
    if (logicalPixels == null || logicalPixels <= 0) {
      return null;
    }

    return (logicalPixels * 2).round();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ColoredBox(
      color: color,
      child: AppShimmer(child: ColoredBox(color: color)),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(Icons.restaurant, size: iconSize)),
    );
  }
}
