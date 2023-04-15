import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ImageWidget extends StatefulWidget {
  final String imageUrl;
  final Function placeholder, errorWidget;
  final double height, width;
  final int memCacheHeight,
      memCacheWidth,
      maxHeightDiskCache,
      maxWidthDiskCache;
  final Duration fadeInDuration;
  final BoxFit fit;
  final bool doNotShowPlaceHolder;

  ImageWidget(
      {@required this.imageUrl,
      this.errorWidget,
      this.placeholder,
      this.height,
      this.width,
      this.maxHeightDiskCache,
      this.maxWidthDiskCache,
      this.memCacheWidth,
      this.memCacheHeight,
      this.fadeInDuration,
      this.fit,
      this.doNotShowPlaceHolder});

  @override
  _ImageWidgetState createState() =>
      _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return OptimizedCacheImage(
      fadeInDuration: widget.fadeInDuration ?? Duration(milliseconds: 0),
      height: widget.height ?? null,
      width: widget.width ?? null,
      memCacheHeight: widget.memCacheHeight ?? null,
      memCacheWidth: widget.memCacheWidth ?? null,
      maxHeightDiskCache: widget.memCacheHeight ?? null,
      maxWidthDiskCache: widget.maxWidthDiskCache ?? null,
      imageUrl: widget.imageUrl,
      fit: widget.fit ?? null,
      placeholder: widget.doNotShowPlaceHolder == true
          ? null
          : widget.placeholder ??
              (context, url) =>
                  widget.placeholder ??
                  Image.asset("assets/images/placeholder.webp"),
      errorWidget: widget.errorWidget ??
          (context, error, stackTrace) =>
              widget.errorWidget ??
              Image.asset("assets/images/placeholder.webp"),
    );
  }
}
