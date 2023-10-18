import 'dart:io';

import 'package:flutter/material.dart';
import 'package:theme_detector/theme_detector.dart';

import 'config.dart';
import 'models/dock_item.dart';
import 'views/dock.dart';

Future<void> main() async {
  print(Platform.environment['XDG_CONFIG_HOME']);

  final config = await Config.init();

  WidgetsFlutterBinding.ensureInitialized();

  final gtkIconThemeName = (await Process.run('gsettings', [
    'get',
    'org.gnome.desktop.interface',
    'icon-theme',
  ]))
      .stdout
      .toString()
      .trim()
      .replaceAll('\'', '');

  runApp(Docklett(gtkIconThemeName: gtkIconThemeName));
}

class Docklett extends StatelessWidget {
  final String? gtkIconThemeName;
  Docklett({super.key, this.gtkIconThemeName});

  final Future<List<DockItem>> _fetchDirectory =
      Directory("${Platform.environment['HOME']!}/videos/record")
          .list()
          .where((final fileSystemEntity) {
            final uri = fileSystemEntity.absolute.uri;

            return uri.pathSegments.last.isNotEmpty &&
                !uri.pathSegments.last.startsWith('.');
          })
          .map((final fileSystemEntity) =>
              DockItem.from(fileSystemEntity.absolute.uri, (final int _) {}))
          .toList();

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
      future: _fetchDirectory,
      builder: (final context, final snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          color: Colors.transparent,
          home: Dock(
            gtkIconThemeName: gtkIconThemeName,
            listItem: snapshot.data ?? [],
          ),
        );
      },
    );
  }
}
