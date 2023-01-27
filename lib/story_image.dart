import 'package:flutter/material.dart';

/// StoryImage
enum StoryImageLoadingState {
  loading,
  available,
}

class StoryImageLoadingController
    extends ValueNotifier<StoryImageLoadingState> {
  StoryImageLoadingController._() : super(StoryImageLoadingState.available);
}

final storyImageLoadingController = StoryImageLoadingController._();

class StoryImage extends StatefulWidget {
  const StoryImage({
    required super.key,
    required this.imageProvider,
    this.loadingBuilder,
    this.frameBuilder,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  });

  final ImageProvider<Object> imageProvider;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;

  @override
  State<StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  late final ImageStreamListener imageStreamListener;

  @override
  void initState() {
    super.initState();
    storyImageLoadingController.value = StoryImageLoadingState.loading;
    imageStreamListener = ImageStreamListener(
      (image, synchronousCall) {
        storyImageLoadingController.value = StoryImageLoadingState.available;
      },
    );
    widget.imageProvider
        .resolve(ImageConfiguration())
        .addListener(imageStreamListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.imageProvider,
      frameBuilder: widget.frameBuilder,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );
  }
}
