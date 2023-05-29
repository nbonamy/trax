import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/app_icon.dart';
import '../components/button.dart';
import '../components/draggable_dialog.dart';
import '../model/preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: SettingsWidget(),
        );
      },
    );
  }
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late Preferences _preferences;
  late String _musicFolder;
  late ImportFileOp _importFileOp;
  late bool _keepMediaOrganized;
  late LyricsSaveMode _lyricsSaveMode;

  @override
  void initState() {
    super.initState();
    _preferences = Preferences.of(context);
    _musicFolder = _preferences.musicFolder;
    _importFileOp = _preferences.importFileOp;
    _keepMediaOrganized = _preferences.keepMediaOrganized;
    _lyricsSaveMode = _preferences.lyricsSaveMode;
  }

  @override
  Widget build(BuildContext context) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    return DraggableDialog(
      width: 550,
      height: 340,
      headerBgColor: const Color.fromRGBO(240, 234, 230, 1.0),
      //: const Color.fromRGBO(240, 234, 230, 1.0),
      // contentsBgColor: const Color.fromRGBO(246, 240, 236, 1.0),
      header: Row(
        children: [
          const AppIcon(size: 80),
          const SizedBox(width: 16),
          Text(
            t.settingsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          _row(t.settingsMusicFolder, 1, [
            Text(_musicFolder),
            const SizedBox(width: 16),
            Button(
              t.browse,
              onPressed: () async {
                String? folder = await FilePicker.platform.getDirectoryPath(
                  initialDirectory: Directory(_musicFolder).existsSync()
                      ? _musicFolder
                      : null,
                );
                setState(() {
                  _musicFolder = folder ?? _musicFolder;
                });
              },
              horizontalPadding: 8,
            ),
          ]),
          _row(t.settingsImportOptions, 1, [
            MacosPopupButton(
              value: _importFileOp,
              items: [
                MacosPopupMenuItem(
                  value: ImportFileOp.copy,
                  child: Text(t.importFileOpCopy),
                ),
                MacosPopupMenuItem(
                  value: ImportFileOp.move,
                  child: Text(t.importFileOpMove),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _importFileOp = v ?? _importFileOp;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(t.settingsImportFileOpDesc),
          ]),
          _row('', 1, [
            MacosCheckbox(
              value: _keepMediaOrganized,
              onChanged: (b) => setState(
                () {
                  _keepMediaOrganized = b;
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(t.settingsKeepOrganizedDesc),
          ]),
          _row(t.settingsLyrics, 1, [
            Text(t.settingsLyricsSaveMode),
            const SizedBox(width: 8),
            MacosPopupButton(
              value: _lyricsSaveMode,
              items: [
                MacosPopupMenuItem(
                  value: LyricsSaveMode.tag,
                  child: Text(t.settingsLyricsSaveModeTags),
                ),
                MacosPopupMenuItem(
                  value: LyricsSaveMode.lrc,
                  child: Text(t.settingsLyricsSaveModeLrc),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _lyricsSaveMode = v ?? _lyricsSaveMode;
                });
              },
            ),
          ]),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button(t.cancel, onPressed: _onClose),
          const SizedBox(width: 8),
          Button(t.save, onPressed: _onSave, defaultButton: true),
        ],
      ),
    );
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onSave() async {
    _save();
    _onClose();
  }

  void _save() {
    _preferences.musicFolder = _musicFolder;
    _preferences.importFileOp = _importFileOp;
    _preferences.keepMediaOrganized = _keepMediaOrganized;
    _preferences.lyricsSaveMode = _lyricsSaveMode;
  }

  Widget _row(String label, double paddingTop, List<Widget> widgets) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, paddingTop),
          ...widgets,
        ],
      ),
    );
  }

  Widget _label(String label, double paddingTop) {
    return SizedBox(
      width: 120,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop, right: 12),
        child: Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(125, 125, 125, 1.0),
          ),
        ),
      ),
    );
  }
}
