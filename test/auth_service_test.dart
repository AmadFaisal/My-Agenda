import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ujian_uts_amad/services/auth_service.dart';

void main() {
  test('shows a clear warning for incorrect login credentials', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'message': 'The provided credentials are incorrect.'}),
        401,
      ),
    );

    await expectLater(
      AuthService.login('wrong@example.com', 'wrong-password', client: client),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Email atau kata sandi salah'),
        ),
      ),
    );
    client.close();
  });

  test('shows a clear warning when the registration email is taken', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'message': 'The given data was invalid.',
          'errors': {
            'email': ['The email has already been taken.'],
          },
        }),
        422,
      ),
    );

    await expectLater(
      AuthService.register(
        'Test User',
        'existing@example.com',
        'password123',
        client: client,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Email sudah terdaftar'),
        ),
      ),
    );
    client.close();
  });

  test('shows a warning when the registration password is rejected', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'message': 'The given data was invalid.',
          'errors': {
            'password': ['The password must be at least 8 characters.'],
          },
        }),
        422,
      ),
    );

    await expectLater(
      AuthService.register(
        'Test User',
        'test@example.com',
        'short',
        client: client,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Kata sandi tidak memenuhi persyaratan'),
        ),
      ),
    );
    client.close();
  });
}
