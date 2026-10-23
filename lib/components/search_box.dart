import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import 'trax_colors.dart';

class SearchBoxWidget extends StatelessWidget {
  const SearchBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: MacosSearchField(
        decoration: BoxDecoration(
          color: colors.well,
          border: Border.all(color: colors.line),
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
