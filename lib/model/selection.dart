import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'track.dart';

class SelectionModel extends ChangeNotifier {
  final TrackList _selection = [];

  bool get isEmpty {
    return _selection.isEmpty;
  }

  List<Track> get get => List.from(_selection);

  static SelectionModel of(BuildContext context) {
    return Provider.of<SelectionModel>(context, listen: false);
  }

  bool contains(Track item) {
    return _selection.contains(item);
  }

  void clear({bool notify = true}) {
    if (_selection.isNotEmpty) {
      _selection.clear();
      if (notify) {
        notifyListeners();
      }
    }
  }

  void add(Track item, {bool notify = true}) {
    if (_selection.contains(item) == false) {
      _selection.add(item);
      if (notify) {
        notifyListeners();
      }
    }
  }

  void remove(Track item, {bool notify = true}) {
    if (_selection.contains(item) == true) {
      _selection.remove(item);
      if (notify) {
        notifyListeners();
      }
    }
  }

  void toggle(Track item, {bool notify = true}) {
    if (_selection.contains(item)) {
      remove(item, notify: notify);
    } else {
      add(item, notify: notify);
    }
  }

  void set(TrackList items, {bool notify = true}) {
    _selection.clear();
    _selection.addAll(items);
    if (notify) {
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }
}
