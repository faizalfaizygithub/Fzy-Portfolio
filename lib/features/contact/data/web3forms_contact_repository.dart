import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/contact_message.dart';

/// Sends contact messages through Web3Forms (https://web3forms.com), which
/// forwards them to the email address the access key was created for.
///
/// The access key is public by design (it can only send to that inbox) and
/// is supplied at build time:
///
///   flutter build web --dart-define=WEB3FORMS_ACCESS_KEY=xxxxxxxx
class Web3FormsContactRepository implements ContactRepository {
  Web3FormsContactRepository({
    http.Client? client,
    String? accessKey,
    this.timeout = const Duration(seconds: 20),
  })  : _client = client ?? http.Client(),
        _accessKey = accessKey ?? const String.fromEnvironment('WEB3FORMS_ACCESS_KEY');

  static final _endpoint = Uri.parse('https://api.web3forms.com/submit');

  final http.Client _client;
  final String _accessKey;
  final Duration timeout;

  bool get isConfigured => _accessKey.isNotEmpty;

  @override
  Future<ContactResult> send(ContactMessage message) async {
    if (!isConfigured) {
      return const ContactFailure(
        'The contact form isn\'t connected yet. Please email me directly instead.',
      );
    }

    try {
      final response = await _client
          .post(
            _endpoint,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'access_key': _accessKey,
              'name': message.name,
              'email': message.email,
              'subject': 'Portfolio: ${message.subject}',
              'message': message.message,
              'from_name': 'Portfolio contact form',
              'replyto': message.email,
            }),
          )
          .timeout(timeout);

      // Only report success when the service explicitly confirms it.
      Map<String, dynamic>? body;
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        body = null;
      }
      if (response.statusCode == 200 && body?['success'] == true) {
        return const ContactSuccess();
      }
      debugPrint('Contact form failed: ${response.statusCode} ${response.body}');
      return const ContactFailure(
        'Your message couldn\'t be delivered. Please try again or email me directly.',
      );
    } on TimeoutException {
      return const ContactFailure(
        'The request timed out. Please check your connection and try again.',
      );
    } catch (e) {
      debugPrint('Contact form error: $e');
      return const ContactFailure(
        'Something went wrong while sending. Please try again or email me directly.',
      );
    }
  }
}
