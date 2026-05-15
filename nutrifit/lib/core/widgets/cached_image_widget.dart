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
    // Vừa hiện ảnh mạng, vừa âm thầm tải về cho lần sau
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
    return placeholder ?? Container(
      width: width,
      height: height,
      color: const Color(0xFFF7F8F8),
      child: Icon(
        type == 'foods' ? Icons.fastfood : Icons.fitness_center,
        color: const Color(0xFFC050F6).withValues(alpha: 0.3),
      ),
    );
  }
}
