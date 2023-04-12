import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/preferences.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(128),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.welcome,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Your Music folder is: '),
              Text(
                Preferences.of(context).musicFolder,
                style: const TextStyle(fontFamily: 'Courier'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
