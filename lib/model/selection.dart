import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'track.dart';

typedef Selection = UnmodifiableListView<String>;

class SelectionModel extends ChangeNotifier {
  final List<Track> _selection = [];

  UnmodifiableListView<Track> get get => UnmodifiableListView(_selection);

  static SelectionModel of(BuildContext context) {
    return Provider.of<SelectionModel>(context, listen: false);
  }

  Track? get lastSelected {
    return _selection.isEmpty ? null : _selection.last;
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

  void set(List<Track> items, {bool notify = true}) {
    _selection.clear();
    _selection.addAll(items);
    if (notify) {
      notifyListeners();
    }
  }
}
