import 'package:flutter/foundation.dart';

/// Whether the opening preloader has finished. The hero waits for this
/// before playing its entrance.
class IntroController extends ChangeNotifier {
  IntroController({bool done = false}) : _done = done;

  bool _done;
  bool get done => _done;

  void finish() {
    if (_done) return;
    _done = true;
    notifyListeners();
  }
}
