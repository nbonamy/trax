import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../model/preferences.dart';
import 'draggable_widget.dart';
import 'glass.dart';
import 'trax_colors.dart';

class DraggableDialog extends StatefulWidget {
  static const kDialogBorderRadius = 16.0;
  final double width;
  final double height;
  final Widget header;
  final Widget body;
  final Widget footer;
  final String? preferenceKey;
  final Color? headerBgColor;
  final Color? contentsBgColor;
  const DraggableDialog({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.body,
    required this.footer,
    this.preferenceKey,
    this.headerBgColor,
    this.contentsBgColor,
  });

  @override
  State<DraggableDialog> createState() => _DraggableDialogState();
}

class _DraggableDialogState extends State<DraggableDialog> {
  Alignment _alignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    if (widget.preferenceKey != null) {
      _alignment =
          Preferences.of(context).getDialogAlignment(widget.preferenceKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    // the header is a faint wash over the glass, not a solid slab
    final Color headerBg = widget.headerBgColor ?? colors.hover;
    final Color? contentsBg = widget.contentsBgColor;
    return Align(
      alignment: _alignment,
      child: DraggableWidget(
        alignSelf: false,
        initialAlign: _alignment,
        onAlign: (alignment) {
          setState(() {
            _alignment = alignment;
            if (widget.preferenceKey != null) {
              Preferences.of(context).saveEditorAlignment(
                widget.preferenceKey!,
                _alignment,
              );
            }
          });
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          // translucent: what is behind the dialog shows through, blurred
          // controls sit on solid fields so they read clearly on the glass
          child: MacosPopupButtonTheme(
            data: MacosPopupButtonTheme.of(context).copyWith(
              backgroundColor: colors.field,
            ),
            child: GlassSurface(
              radius: DraggableDialog.kDialogBorderRadius,
              style: GlassStyle.panelForBrightness(colors.brightness),
              child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: headerBg,
                      border: Border(
                        bottom: BorderSide(color: colors.line, width: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    child: widget.header,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: contentsBg,
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(child: widget.body),
                          const SizedBox(height: 16),
                          widget.footer,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
