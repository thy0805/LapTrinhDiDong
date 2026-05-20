import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/core/services/media_service.dart';

class CachedImageWidget extends StatelessWidget {
  final String id;
  final String type; // 'foods' hoặc 'exercises'
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const CachedImageWidget({
    super.key,
    required this.id,
    required this.type,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _buildPlaceholder();
    }

    final mediaService = Get.find<MediaService>();
    final localPath = mediaService.getLocalPath(id, type, url);

    if (mediaService.isFileExists(localPath)) {
      return Image.file(
        File(localPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildNetworkImage(mediaService),
      );
    } else {
      return _buildNetworkImage(mediaService);
    }
  }

  Widget _buildNetworkImage(MediaService mediaService) {
    mediaService.downloadAndSaveFile(id, type, url);
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    IconData iconData;
    if (type == 'foods') {
      iconData = Icons.fastfood;
    } else if (type == 'exercises') {
      iconData = Icons.fitness_center;
    } else if (type == 'avatars') {
      iconData = Icons.person;
    } else {
      iconData = Icons.image;
    }
    return placeholder ?? Container(
      width: width,
      height: height,
      color: const Color(0xFFF7F8F8),
      child: Icon(
        iconData,
        color: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }
}
