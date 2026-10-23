import 'package:flutter/material.dart';

import '../model/preferences.dart';
import 'draggable_widget.dart';
import 'trax_colors.dart';

class DraggableDialog extends StatefulWidget {
  static const kDialogBorderRadius = 8.0;
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
    final Color headerBg = widget.headerBgColor ?? colors.sidebar;
    final Color contentsBg = widget.contentsBgColor ?? colors.background;
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
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: colors.line, width: 0.5),
            borderRadius: const BorderRadius.all(
              Radius.circular(DraggableDialog.kDialogBorderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                spreadRadius: 2,
                blurRadius: 36,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.only(
                    topLeft:
                        Radius.circular(DraggableDialog.kDialogBorderRadius),
                    topRight:
                        Radius.circular(DraggableDialog.kDialogBorderRadius),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: widget.header,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: contentsBg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft:
                          Radius.circular(DraggableDialog.kDialogBorderRadius),
                      bottomRight:
                          Radius.circular(DraggableDialog.kDialogBorderRadius),
                    ),
                  ),
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
    );
  }
}
