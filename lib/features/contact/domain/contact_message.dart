import 'package:flutter/foundation.dart';

@immutable
class ContactMessage {
  const ContactMessage({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String name;
  final String email;
  final String subject;
  final String message;
}

/// Outcome of sending a message. [ContactFailure.message] is user-facing.
sealed class ContactResult {
  const ContactResult();
}

class ContactSuccess extends ContactResult {
  const ContactSuccess();
}

class ContactFailure extends ContactResult {
  const ContactFailure(this.message);
  final String message;
}

abstract interface class ContactRepository {
  Future<ContactResult> send(ContactMessage message);
}

/// Form field validation rules. Return null when valid.
abstract final class ContactValidators {
  static final _email = RegExp(r"^[\w.!#$%&'*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$");

  static String? name(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please enter your name.';
    if (value.length < 2) return 'Name looks too short.';
    if (value.length > 100)
      return 'Please keep your name under 100 characters.';
    return null;
  }

  static String? email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please enter your email.';
    if (!_email.hasMatch(value)) return 'Please enter a valid email address.';
    return null;
  }

  static String? subject(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please add a subject.';
    if (value.length > 150)
      return 'Please keep the subject under 150 characters.';
    return null;
  }

  static String? message(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please write a message.';
    if (value.length < 10)
      return 'Please add a little more detail (10+ characters).';
    if (value.length > 5000)
      return 'Please keep your message under 5000 characters.';
    return null;
  }
}
