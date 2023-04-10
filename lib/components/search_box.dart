import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class SearchBoxWidget extends StatelessWidget {
  const SearchBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: MacosSearchField(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 222, 217, 1.0),
          border: Border.all(color: const Color.fromRGBO(224, 217, 212, 1.0)),
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 4,
        ),
      ),
    );
  }
}
