enum DockItemKind {
  file,
  directory,
  application,
}

enum MimeType {
  applicationDart,
  applicationXBlender,
  applicationXKrita,
  applicationXShellScript,
  applicationVndAndroidPackageArchive,
  audioXGeneric,
  textXJavascript,
  textXRust,
  textXGeneric,
  videoXGeneric,
}

class DockItem {
  DockItemKind kind;
  MimeType? mimeType;
  bool hasThumbnail;
  Uri uri;
  void Function(int)? onSelectCallback;

  DockItem({
    required this.kind,
    required this.uri,
    this.onSelectCallback,
    this.mimeType,
    this.hasThumbnail = false,
  }) : assert(
          kind == DockItemKind.file || !hasThumbnail,
          'Only file could have a thumbnail',
        );

  factory DockItem.from(
    final Uri uri,
    final void Function(int)? onSelectCallback,
  ) {
    if (uri.pathSegments.last.isEmpty) {
      return DockItem(
        kind: DockItemKind.directory,
        uri: uri,
        onSelectCallback: onSelectCallback,
      );
    }

    final ext = uri.pathSegments.last.split('.').last;

    if (ext == 'gif' || ext == 'jpeg' || ext == 'jpg' || ext == 'png') {
      return DockItem(
        kind: DockItemKind.file,
        uri: uri,
        hasThumbnail: true,
        //TODO: I don't remember this
        onSelectCallback: (final int _) {},
      );
    }

    final mimeType = switch (ext) {
      'apk' => MimeType.applicationVndAndroidPackageArchive,
      'blend' => MimeType.applicationXBlender,
      'dart' => MimeType.applicationDart,
      'kra' => MimeType.applicationXKrita,
      'mp3' || 'ogg' || 'wav' => MimeType.audioXGeneric,
      'mp4' => MimeType.videoXGeneric,
      'rs' => MimeType.textXRust,
      'sh' => MimeType.applicationXShellScript,
      'js' => MimeType.textXJavascript,
      _ => MimeType.textXGeneric,
    };

    return DockItem(
      kind: DockItemKind.file,
      uri: uri,
      mimeType: mimeType,
      onSelectCallback: onSelectCallback,
    );
  }

  String getSvgPath({final String? gtkIconThemeName}) {
    var svgFile = '/usr/share/icons/${gtkIconThemeName ?? "default"}/32x32/';

    switch (kind) {
      case DockItemKind.file:
        svgFile += 'mimetypes/';
        switch (mimeType) {
          case MimeType.applicationDart:
            svgFile += 'application-dart';
          case MimeType.textXRust:
            svgFile += 'text-x-rust';
          case MimeType.applicationXBlender:
            svgFile += 'application-x-blender';
          case MimeType.applicationXKrita:
            svgFile += 'application-x-krita';
          case MimeType.applicationXShellScript:
            svgFile += 'application-x-shellscript';
          case MimeType.textXJavascript:
            svgFile += 'application-javascript';
          case _:
            svgFile += 'text-x-generic';
        }
      case _:
        svgFile += 'places/folder';
    }

    return svgFile += '.svg';
  }
}
