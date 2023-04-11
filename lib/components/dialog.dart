import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  static const kDialogBorderRadius = 8.0;
  final double width;
  final double height;
  final Widget header;
  final Widget body;
  final Widget footer;
  const DialogWidget({
    super.key,
    required this.width,
    required this.height,
    required this.header,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(238, 232, 230, 1.0),
            width: 0.25,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(kDialogBorderRadius),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(170, 170, 170, 1),
              spreadRadius: 8,
              blurRadius: 24,
            )
          ]),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(238, 232, 230, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kDialogBorderRadius),
                topRight: Radius.circular(kDialogBorderRadius),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: header,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(kDialogBorderRadius),
                  bottomRight: Radius.circular(kDialogBorderRadius),
                ),
              ),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(child: body),
                  const SizedBox(height: 24),
                  footer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
