import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fzy_portfolio/features/contact/data/web3forms_contact_repository.dart';
import 'package:fzy_portfolio/features/contact/domain/contact_message.dart';
import 'package:fzy_portfolio/features/contact/presentation/providers/contact_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _message = ContactMessage(
  name: 'Jane',
  email: 'jane@example.com',
  subject: 'Hello',
  message: 'I would like to talk about a project.',
);

class _FakeRepo implements ContactRepository {
  _FakeRepo(this.result);
  final ContactResult result;
  @override
  Future<ContactResult> send(ContactMessage message) async => result;
}

void main() {
  group('ContactValidators', () {
    test('name', () {
      expect(ContactValidators.name(''), isNotNull);
      expect(ContactValidators.name(' a '), isNotNull);
      expect(ContactValidators.name('Jane'), isNull);
    });

    test('email', () {
      expect(ContactValidators.email(''), isNotNull);
      expect(ContactValidators.email('jane'), isNotNull);
      expect(ContactValidators.email('jane@'), isNotNull);
      expect(ContactValidators.email('jane@example'), isNotNull);
      expect(ContactValidators.email('jane.doe+x@example.co.in'), isNull);
    });

    test('subject and message', () {
      expect(ContactValidators.subject('  '), isNotNull);
      expect(ContactValidators.subject('Hi'), isNull);
      expect(ContactValidators.message('short'), isNotNull);
      expect(ContactValidators.message('This is long enough.'), isNull);
    });
  });

  group('Web3FormsContactRepository', () {
    Web3FormsContactRepository repo(MockClientHandler handler, {String key = 'k'}) =>
        Web3FormsContactRepository(client: MockClient(handler), accessKey: key);

    test('fails without calling the network when not configured', () async {
      var called = false;
      final r = repo((_) async {
        called = true;
        return http.Response('{}', 200);
      }, key: '');
      expect(await r.send(_message), isA<ContactFailure>());
      expect(called, isFalse);
    });

    test('succeeds only when the service confirms success', () async {
      late Map<String, dynamic> sent;
      final r = repo((req) async {
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response('{"success": true}', 200);
      });
      expect(await r.send(_message), isA<ContactSuccess>());
      expect(sent['access_key'], 'k');
      expect(sent['email'], 'jane@example.com');
      expect(sent['replyto'], 'jane@example.com');
    });

    test('HTTP 200 with success=false is a failure', () async {
      final r = repo((_) async => http.Response('{"success": false}', 200));
      expect(await r.send(_message), isA<ContactFailure>());
    });

    test('server errors and invalid bodies are failures', () async {
      expect(await repo((_) async => http.Response('oops', 500)).send(_message), isA<ContactFailure>());
      expect(await repo((_) async => http.Response('not json', 200)).send(_message), isA<ContactFailure>());
    });

    test('network exceptions are failures', () async {
      final r = repo((_) async => throw http.ClientException('offline'));
      expect(await r.send(_message), isA<ContactFailure>());
    });
  });

  group('ContactProvider', () {
    test('reports success only on delivery', () async {
      final p = ContactProvider(_FakeRepo(const ContactSuccess()));
      final states = <ContactStatus>[];
      p.addListener(() => states.add(p.status));
      expect(await p.submit(_message), isTrue);
      expect(states, [ContactStatus.sending, ContactStatus.success]);
    });

    test('failure keeps error message and never reports success', () async {
      final p = ContactProvider(_FakeRepo(const ContactFailure('nope')));
      expect(await p.submit(_message), isFalse);
      expect(p.status, ContactStatus.failure);
      expect(p.error, 'nope');
      p.reset();
      expect(p.status, ContactStatus.idle);
      expect(p.error, isNull);
    });
  });
}
