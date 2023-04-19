import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/app_icon.dart';
import '../model/menu_actions.dart';
import '../model/preferences.dart';
import '../utils/events.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(128),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIcon(size: 128),
                Text(
                  t.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(4, 90, 156, 1.0),
                    fontSize: 116,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            RichText(
              text: TextSpan(
                children: [
                  _span(context, t.welcomeLibraryLocation),
                  _span(
                    context,
                    Preferences.of(context).musicFolder,
                    style: _textStyle(context).copyWith(
                      fontFamily: 'Courier',
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  _span(context, t.welcomeActionsIntro),
                  _link(
                    context,
                    t.welcomeActionChange,
                    () =>
                        eventBus.fire(MenuActionEvent(MenuAction.appSettings)),
                  ),
                  _span(context, t.welcomeActionsOr),
                  _link(
                    context,
                    t.welcomeActionScan,
                    () =>
                        eventBus.fire(MenuActionEvent(MenuAction.fileRefresh)),
                  ),
                  _span(context, t.welcomeActionsEnd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _span(BuildContext context, String text, {TextStyle? style}) {
    return TextSpan(text: text, style: style ?? _textStyle(context));
  }

  TextSpan _link(BuildContext context, String text, GestureTapCallback onTap) {
    return TextSpan(
      text: text,
      style: _linkStyle(context),
      mouseCursor: SystemMouseCursors.click,
      recognizer: TapGestureRecognizer()..onTap = () => onTap(),
    );
  }

  TextStyle _textStyle(BuildContext context) {
    return DefaultTextStyle.of(context).style.copyWith(fontSize: 18);
  }

  TextStyle _linkStyle(BuildContext context) {
    return _textStyle(context).copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );
  }
}
