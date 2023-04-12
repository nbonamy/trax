import 'package:flutter/material.dart';

import '../model/preferences.dart';
import 'draggable_widget.dart';

class DraggableDialog extends StatefulWidget {
  static const kDialogBorderRadius = 8.0;
  final double width;
  final double height;
  final Widget header;
  final Widget body;
  final Widget footer;
  final String? preferenceKey;
  final Color headerBgColor;
  final Color contentsBgColor;
  const DraggableDialog({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.body,
    required this.footer,
    this.preferenceKey,
    this.headerBgColor = const Color.fromRGBO(238, 232, 230, 1.0),
    this.contentsBgColor = Colors.white,
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
            border: Border.all(
              color: widget.headerBgColor,
              width: 0.25,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(DraggableDialog.kDialogBorderRadius),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(170, 170, 170, 1),
                spreadRadius: 8,
                blurRadius: 24,
              )
            ],
          ),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.headerBgColor,
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
                    color: widget.contentsBgColor,
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
                      const SizedBox(height: 24),
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
