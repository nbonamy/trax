import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The macOS display accessibility options that change how glass is drawn.
///
/// Flutter does not expose "Reduce transparency" nor "Increase contrast", so
/// they come from the runner (see MainFlutterWindow.swift) and are kept up to
/// date when the user flips them in System Settings.
class SystemAccessibility extends ChangeNotifier {
  static final SystemAccessibility instance = SystemAccessibility();
  static const MethodChannel _channel = MethodChannel('trax/accessibility');

  bool _reduceTransparency = false;
  bool _increaseContrast = false;

  /// Glass must become a plain opaque surface.
  bool get reduceTransparency => _reduceTransparency;

  /// Edges and separators need to be clearly visible.
  bool get increaseContrast => _increaseContrast;

  Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'changed') _apply(call.arguments);
    });
    try {
      _apply(await _channel.invokeMethod('get'));
    } on MissingPluginException {
      // not running inside the macOS runner (tests): keep the defaults
    } on PlatformException {
      // same
    }
  }

  void _apply(dynamic state) {
    if (state is! Map) return;
    final bool reduce = state['reduceTransparency'] == true;
    final bool contrast = state['increaseContrast'] == true;
    set(reduceTransparency: reduce, increaseContrast: contrast);
  }

  void set({bool? reduceTransparency, bool? increaseContrast}) {
    final bool reduce = reduceTransparency ?? _reduceTransparency;
    final bool contrast = increaseContrast ?? _increaseContrast;
    if (reduce == _reduceTransparency && contrast == _increaseContrast) return;
    _reduceTransparency = reduce;
    _increaseContrast = contrast;
    notifyListeners();
  }
}
