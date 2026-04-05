// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFilesGen {
  const $AssetsFilesGen();

  /// File path: assets/files/form_exec_file_test.json
  String get formExecFileTest => 'assets/files/form_exec_file_test.json';

  /// File path: assets/files/form_manager_test.json
  String get formManagerTest => 'assets/files/form_manager_test.json';

  /// File path: assets/files/menu_schema 2.json
  String get menuSchema2 => 'assets/files/menu_schema 2.json';

  /// File path: assets/files/menu_schema.json
  String get menuSchema => 'assets/files/menu_schema.json';

  /// List of all assets
  List<String> get values => [
    formExecFileTest,
    formManagerTest,
    menuSchema2,
    menuSchema,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/common
  $AssetsImagesCommonGen get common => const $AssetsImagesCommonGen();

  /// Directory path: assets/images/views
  $AssetsImagesViewsGen get views => const $AssetsImagesViewsGen();
}

class $AssetsImagesCommonGen {
  const $AssetsImagesCommonGen();

  /// Directory path: assets/images/common/lists
  $AssetsImagesCommonListsGen get lists => const $AssetsImagesCommonListsGen();

  /// Directory path: assets/images/common/logos
  $AssetsImagesCommonLogosGen get logos => const $AssetsImagesCommonLogosGen();

  /// Directory path: assets/images/common/upload
  $AssetsImagesCommonUploadGen get upload =>
      const $AssetsImagesCommonUploadGen();
}

class $AssetsImagesViewsGen {
  const $AssetsImagesViewsGen();

  /// Directory path: assets/images/views/login
  $AssetsImagesViewsLoginGen get login => const $AssetsImagesViewsLoginGen();
}

class $AssetsImagesCommonListsGen {
  const $AssetsImagesCommonListsGen();

  /// File path: assets/images/common/lists/list_empty_state.png
  AssetGenImage get listEmptyState =>
      const AssetGenImage('assets/images/common/lists/list_empty_state.png');

  /// List of all assets
  List<AssetGenImage> get values => [listEmptyState];
}

class $AssetsImagesCommonLogosGen {
  const $AssetsImagesCommonLogosGen();

  /// File path: assets/images/common/logos/logo_01.png
  AssetGenImage get logo01 =>
      const AssetGenImage('assets/images/common/logos/logo_01.png');

  /// File path: assets/images/common/logos/logo_02.png
  AssetGenImage get logo02 =>
      const AssetGenImage('assets/images/common/logos/logo_02.png');

  /// List of all assets
  List<AssetGenImage> get values => [logo01, logo02];
}

class $AssetsImagesCommonUploadGen {
  const $AssetsImagesCommonUploadGen();

  /// File path: assets/images/common/upload/dream-room.png
  AssetGenImage get dreamRoom =>
      const AssetGenImage('assets/images/common/upload/dream-room.png');

  /// File path: assets/images/common/upload/image-fox.png
  AssetGenImage get imageFox =>
      const AssetGenImage('assets/images/common/upload/image-fox.png');

  /// File path: assets/images/common/upload/minimalist-tree.png
  AssetGenImage get minimalistTree =>
      const AssetGenImage('assets/images/common/upload/minimalist-tree.png');

  /// List of all assets
  List<AssetGenImage> get values => [dreamRoom, imageFox, minimalistTree];
}

class $AssetsImagesViewsLoginGen {
  const $AssetsImagesViewsLoginGen();

  /// File path: assets/images/views/login/login.png
  AssetGenImage get login =>
      const AssetGenImage('assets/images/views/login/login.png');

  /// List of all assets
  List<AssetGenImage> get values => [login];
}

class Assets {
  const Assets._();

  static const $AssetsFilesGen files = $AssetsFilesGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
