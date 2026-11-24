import 'package:flutter/foundation.dart';

import '../../domain/contact_message.dart';

enum ContactStatus { idle, sending, success, failure }

class ContactProvider extends ChangeNotifier {
  ContactProvider(this._repository);

  final ContactRepository _repository;

  ContactStatus _status = ContactStatus.idle;
  String? _error;
  bool _disposed = false;

  ContactStatus get status => _status;
  String? get error => _error;
  bool get isSending => _status == ContactStatus.sending;

  /// Returns true only when the message was actually delivered.
  Future<bool> submit(ContactMessage message) async {
    if (isSending) return false;
    _set(ContactStatus.sending);

    final result = await _repository.send(message);
    switch (result) {
      case ContactSuccess():
        _set(ContactStatus.success);
        return true;
      case ContactFailure(:final message):
        _set(ContactStatus.failure, error: message);
        return false;
    }
  }

  /// Back to the editable form (e.g. "Send another message").
  void reset() => _set(ContactStatus.idle);

  void _set(ContactStatus status, {String? error}) {
    if (_disposed) return;
    _status = status;
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
