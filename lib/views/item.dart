import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:open_file/open_file.dart';

import '../models/dock_item.dart';

class Item extends StatefulWidget {
  final DockItemKind kind;
  final String? svgFile;
  final bool hasThumbnail;
  final String uri;
  final void Function()? contextMenuOnDismissed;
  final void Function(int)? onSelectCallback;

  const Item({
    required this.kind,
    required this.uri,
    this.onSelectCallback,
    this.svgFile,
    this.hasThumbnail = false,
    this.contextMenuOnDismissed,
    super.key,
  }) : assert(hasThumbnail == false || svgFile != null,
            'when [Item] has a thumbnail, [svgFile] nolonger required');

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 0.2),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticIn,
  ));

  void _onEnter(final PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onExit(final PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });
  }

  void _onFileClicked() {}

  void _onFileOpened(final OpenResult openResult) {}

  @override
  void didUpdateWidget(final Item oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = const Duration(seconds: 1);
  }

  @override
  Widget build(final BuildContext context) {
    final itemIcon = AnimatedContainer(
      padding: EdgeInsets.only(bottom: _isHovered ? 4.0 : 0.0),
      width: _isHovered ? 72 : 42,
      height: _isHovered ? 72 : 42,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeInOut,
      child: SvgPicture.file(
        colorFilter: ColorFilter.mode(
          _isHovered ? Colors.white.withAlpha(0) : Colors.black.withAlpha(80),
          BlendMode.srcATop,
        ),
        File.fromUri(Uri.file(widget.svgFile!)),
        fit: BoxFit.contain,
      ),
    );

    return GestureDetector(
      onTap: () async {
        if (widget.kind == DockItemKind.file) {
          _onFileClicked();
          await OpenFile.open(widget.uri, linuxUseGio: true)
              .then<void>(_onFileOpened);
        }
      },
      onSecondaryTap: () => debugPrint(widget.uri),
      child: Tooltip(
        message: widget.uri.split('/').last,
        waitDuration: const Duration(milliseconds: 800),
        verticalOffset: -60,
        child: ContextMenuRegion(
          menuOffset: const Offset(0, -60),
          onDismissed: widget.contextMenuOnDismissed,
          onItemSelected: (final item) async {
            if (item.title == 'Open') {
              _onFileClicked();
              await OpenFile.open(widget.uri, linuxUseGio: true)
                  .then(_onFileOpened);
            }
            debugPrint('${item.title} was selected');
          },
          menuItems: [
            MenuItem(title: 'Open'),
            MenuItem(title: 'Remove from Dock'),
          ],
          child: MouseRegion(
            onEnter: _onEnter,
            onExit: _onExit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _isHovered
                  ? SlideTransition(
                      position: _offsetAnimation,
                      child: itemIcon,
                    )
                  : itemIcon,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimateOrNo extends StatelessWidget {
  final Widget child;
  final bool animate;
  final Animation<Offset>? offsetAnimation;

  const AnimateOrNo({
    required this.child,
    required this.offsetAnimation,
    super.key,
    this.animate = false,
  });

  @override
  Widget build(final BuildContext context) {
    if (animate) {
      return SlideTransition(position: offsetAnimation!, child: child);
    } else {
      return Container(child: child);
    }
  }
}
