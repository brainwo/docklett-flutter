import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../models/dock_item.dart';
import 'item.dart';

class Dock extends StatefulWidget {
  final String? gtkIconThemeName;
  final List<DockItem> listItem;

  const Dock({
    required this.listItem,
    super.key,
    this.gtkIconThemeName,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  @override
  Widget build(final BuildContext context) {
    final widgetList = widget.listItem
        .map((final item) => Item(
              kind: item.kind,
              svgFile:
                  item.getSvgPath(gtkIconThemeName: widget.gtkIconThemeName),
              uri: item.uri.toFilePath(),
              contextMenuOnDismissed: () async {
                await windowManager.getPosition().then((final position) {
                  windowManager.setPosition(Offset(position.dx, 1080 - 2));
                });
              },
              onSelectCallback: (final int _) {},
            ))
        .toList();

    return MouseRegion(
      onEnter: (final event) async {
        await windowManager.getPosition().then((final position) {
          windowManager.setPosition(Offset(position.dx, 1080 - 108));
        });
      },
      onExit: (final event) async {
        if (event.position.dy <= 0) {
          await windowManager.getPosition().then((final position) {
            windowManager.setPosition(Offset(position.dx, 1080 - 2));
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widgetList,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
