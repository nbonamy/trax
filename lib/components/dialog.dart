import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';

import '../utils/consts.dart';
import 'app_icon.dart';
import 'button.dart';

typedef DialogCallback = void Function(BuildContext);
typedef PromptCallback = void Function(BuildContext, String);

class TraxDialog {
  static void inform({
    required BuildContext context,
    required String message,
  }) {
    AppLocalizations t = AppLocalizations.of(context)!;
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const AppIcon(),
        message: Text(message),
        primaryButton: SizedBox(
          width: 100,
          child: Button(
            t.ok,
            () => Navigator.of(context).pop(),
            verticalPadding: 6,
            defaultButton: true,
          ),
        ),
        title: Text(t.appName),
      ),
    );
  }

  static Future confirm({
    required BuildContext context,
    String? title,
    required String text,
    String? cancelLabel,
    String? confirmLabel,
    required DialogCallback onConfirmed,
    DialogCallback? onCancel,
    bool isDestructive = false,
    Color? barrierColor,
  }) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return showMacosAlertDialog(
      context: context,
      barrierColor: barrierColor,
      builder: (context) => MacosAlertDialog(
        appIcon: const AppIcon(),
        title: Text(
          title ?? AppLocalizations.of(context)?.appName ?? Consts.appName,
          style: MacosTheme.of(context)
              .typography
              .title3
              .copyWith(fontWeight: FontWeight.bold),
        ),
        message: Text(
          text,
          textAlign: TextAlign.center,
          style: MacosTheme.of(context).typography.callout,
        ),
        primaryButton: PushButton(
          isSecondary: isDestructive,
          buttonSize: ButtonSize.large,
          onPressed: () => onConfirmed(context),
          child: Text(confirmLabel ?? t.yes),
        ),
        secondaryButton: PushButton(
          isSecondary: !isDestructive,
          buttonSize: ButtonSize.large,
          onPressed: () => onCancel != null
              ? onCancel(context)
              : Navigator.of(context).pop(),
          child: Text(cancelLabel ?? t.cancel),
        ),
      ),
    );
  }

  static Future<dynamic> prompt({
    required BuildContext context,
    required String text,
    required String value,
    required PromptCallback onConfirmed,
    DialogCallback? onCancel,
    bool isDanger = false,
  }) {
    TextEditingController controller = TextEditingController(text: value);
    AppLocalizations t = AppLocalizations.of(context)!;
    return showMacosSheet(
      context: context,
      builder: (context) => MacosSheet(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 256,
            height: 256,
            child: Column(
              children: [
                Text(text),
                MacosTextField(
                  controller: controller,
                ),
                Row(
                  children: [
                    Expanded(
                      child: PushButton(
                        buttonSize: ButtonSize.small,
                        isSecondary: true,
                        onPressed: () => onCancel != null
                            ? onCancel(context)
                            : Navigator.of(context).pop(),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: PushButton(
                        color: Colors.green,
                        buttonSize: ButtonSize.small,
                        onPressed: () =>
                            onConfirmed(context, controller.value.text),
                        child: Text(t.ok),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
