// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  test('End-to-end Trainer Onboarding integration test', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/api/v1',
      validateStatus: (status) => true,
    ));

    print('=== Starting Onboarding Integration Test ===');

    final phoneNumber = '+91${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    print('Step 1: Requesting OTP for phone: $phoneNumber');
    
    final otpRes = await dio.post('/auth/request-otp', data: {
      'phoneNumber': phoneNumber,
    });

    expect(otpRes.statusCode, anyOf([200, 201]));
    print('SUCCESS: OTP requested.');

    print('Step 2: Verifying OTP with default code 1234');
    final verifyRes = await dio.post(
      '/auth/verify-otp',
      data: {
        'phoneNumber': phoneNumber,
        'code': '1234',
      },
      options: Options(
        headers: {
          'x-client-platform': 'mobile',
        },
      ),
    );

    print('Verify OTP response: ${verifyRes.statusCode} -> ${verifyRes.data}');
    expect(verifyRes.statusCode, anyOf([200, 201]));
    final accessToken = verifyRes.data['accessToken'];
    expect(accessToken, isNotNull);
    print('SUCCESS: Authenticated successfully.');

    print('Step 3: Decoding initial token and checking roles');
    final payload1 = JwtDecoder.decode(accessToken);
    print('  Initial roles: ${payload1['roles']}');
    final initialRoles = (payload1['roles'] as List? ?? []);
    final hasStaffBefore = initialRoles.any((r) => r['roleName'] == 'staff');
    expect(hasStaffBefore, isFalse);
    print('SUCCESS: User does not have staff role initially.');

    print('Step 4: Submitting Trainer Onboarding form via Multipart/Form-data');
    
    final formData = FormData.fromMap({
      'name': 'Jane Integration',
      'experience': '6',
      'bio': 'Automatic integration test trainer.',
      'specializations': 'Weightlifting, Kettlebell',
      'certificates': [
        MultipartFile.fromString(
          'Fake certificate document content',
          filename: 'cert.pdf',
        ),
      ],
    });

    final signupRes = await dio.post(
      '/users/trainer-signup',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    expect(signupRes.statusCode, 200);
    final newAccessToken = signupRes.data['accessToken'];
    expect(newAccessToken, isNotNull);
    print('SUCCESS: Trainer signup API call successful.');

    print('Step 5: Decoding the new token and verifying the role-switch');
    final payload2 = JwtDecoder.decode(newAccessToken);
    print('  Updated roles: ${payload2['roles']}');
    final updatedRoles = (payload2['roles'] as List? ?? []);
    final hasStaffAfter = updatedRoles.any((r) => r['roleName'] == 'staff');
    expect(hasStaffAfter, isTrue);

    print('=== ALL INTEGRATION TESTS PASSED SUCCESSFULLY! ===');
  });

  test('Refresh token rotation: old token is rejected after use', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/api/v1',
      validateStatus: (status) => true,
    ));

    print('=== Starting Refresh Rotation Integration Test ===');

    final phoneNumber = '+91${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}3';
    print('Step 1: Requesting OTP for phone: $phoneNumber');
    final otpRes = await dio.post('/auth/request-otp', data: {
      'phoneNumber': phoneNumber,
    });
    expect(otpRes.statusCode, anyOf([200, 201]));

    print('Step 2: Verifying OTP');
    final verifyRes = await dio.post(
      '/auth/verify-otp',
      data: {'phoneNumber': phoneNumber, 'code': '1234'},
      options: Options(headers: {'x-client-platform': 'mobile'}),
    );
    expect(verifyRes.statusCode, anyOf([200, 201]));
    final originalRefreshToken = verifyRes.data['refreshToken'] as String;
    print('SUCCESS: Authenticated. Got initial token pair.');

    print('Step 3: Refreshing with the original refresh token');
    final refreshRes = await dio.post(
      '/auth/refresh',
      options: Options(headers: {'Authorization': 'Bearer $originalRefreshToken'}),
    );
    expect(refreshRes.statusCode, anyOf([200, 201]));
    final newAccessToken = refreshRes.data['accessToken'] as String;
    final newRefreshToken = refreshRes.data['refreshToken'] as String;
    expect(newAccessToken, isNotNull);
    expect(newRefreshToken, isNotNull);
    // Note: the access token is a JWT signed over {sub, phone, roles, iat,
    // exp} — if issued within the same second as the original it can be
    // byte-identical even though it's a freshly issued token, so we don't
    // assert on it. The refresh token (a random opaque value) reliably
    // proves rotation, backed up by the old-token-rejected check below.
    expect(newRefreshToken, isNot(equals(originalRefreshToken)));
    print('SUCCESS: Refresh rotated to a new refresh token.');

    print('Step 4: Replaying the now-stale original refresh token');
    final staleRefreshRes = await dio.post(
      '/auth/refresh',
      options: Options(headers: {'Authorization': 'Bearer $originalRefreshToken'}),
    );
    expect(staleRefreshRes.statusCode, 401);
    print('SUCCESS: Server rejected the rotated-out refresh token with 401.');

    print('Step 5: Confirming the new refresh token still works');
    final secondRefreshRes = await dio.post(
      '/auth/refresh',
      options: Options(headers: {'Authorization': 'Bearer $newRefreshToken'}),
    );
    expect(secondRefreshRes.statusCode, anyOf([200, 201]));
    print('=== ALL REFRESH ROTATION TESTS PASSED ===');
  });

  test('End-to-end QR Trainer Pairing integration test', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/api/v1',
      validateStatus: (status) => true,
    ));

    print('=== Starting QR Pairing Integration Test ===');

    // 1. Create a Trainer (User A)
    final trainerPhone = '+91${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}1';
    print('Step 1: Requesting OTP for Trainer: $trainerPhone');
    final otpResA = await dio.post('/auth/request-otp', data: {'phoneNumber': trainerPhone});
    expect(otpResA.statusCode, anyOf([200, 201]));

    print('Step 2: Verifying OTP for Trainer');
    final verifyResA = await dio.post(
      '/auth/verify-otp',
      data: {'phoneNumber': trainerPhone, 'code': '1234'},
      options: Options(headers: {'x-client-platform': 'mobile'}),
    );
    expect(verifyResA.statusCode, anyOf([200, 201]));
    final trainerToken = verifyResA.data['accessToken'];
    expect(trainerToken, isNotNull);

    print('Step 3: Upgrading User A to Trainer (staff role)');
    final formData = FormData.fromMap({
      'name': 'Marcus Chen Test',
      'experience': '10',
      'bio': 'Master of movement patterns.',
      'specializations': 'Strength, Yoga',
      'certificates': [
        MultipartFile.fromString('Certificate data', filename: 'cert.pdf'),
      ],
    });
    final signupRes = await dio.post(
      '/users/trainer-signup',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $trainerToken'}),
    );
    expect(signupRes.statusCode, 200);
    final trainerStaffToken = signupRes.data['accessToken'];
    expect(trainerStaffToken, isNotNull);

    print('Step 4: Requesting QR token as Trainer');
    final qrRes = await dio.post(
      '/users/staff/qr-token',
      options: Options(headers: {'Authorization': 'Bearer $trainerStaffToken'}),
    );
    expect(qrRes.statusCode, 200);
    final qrToken = qrRes.data['qrToken'];
    expect(qrToken, isNotNull);
    print('SUCCESS: Generated QR Token: $qrToken');

    // 2. Create a Client/Member (User B)
    final clientPhone = '+91${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}2';
    print('Step 5: Requesting OTP for Client: $clientPhone');
    final otpResB = await dio.post('/auth/request-otp', data: {'phoneNumber': clientPhone});
    expect(otpResB.statusCode, anyOf([200, 201]));

    print('Step 6: Verifying OTP for Client');
    final verifyResB = await dio.post(
      '/auth/verify-otp',
      data: {'phoneNumber': clientPhone, 'code': '1234'},
      options: Options(headers: {'x-client-platform': 'mobile'}),
    );
    expect(verifyResB.statusCode, anyOf([200, 201]));
    final clientToken = verifyResB.data['accessToken'];
    expect(clientToken, isNotNull);

    print('Step 7: Creating Client Profile');
    final profileRes = await dio.post(
      '/users/profile',
      data: {'fullName': 'Marcus Client'},
      options: Options(headers: {'Authorization': 'Bearer $clientToken'}),
    );
    expect(profileRes.statusCode, 201);

    // 3. Pair Client to Trainer
    print('Step 8: Connecting Client to Trainer via QR Token');
    final connectRes = await dio.post(
      '/users/connect-trainer',
      data: {'qrToken': qrToken},
      options: Options(headers: {'Authorization': 'Bearer $clientToken'}),
    );
    expect(connectRes.statusCode, 200);
    expect(connectRes.data['isActive'], isTrue);
    print('SUCCESS: Client connected to Trainer.');

    // 4. Verify Connection from Trainer side
    print('Step 9: Verifying client list on Trainer side');
    final clientsRes = await dio.get(
      '/users/staff/clients',
      options: Options(headers: {'Authorization': 'Bearer $trainerStaffToken'}),
    );
    expect(clientsRes.statusCode, 200);
    final clientsList = clientsRes.data as List;
    expect(clientsList.any((c) => c['fullName'] == 'Marcus Client'), isTrue);
    print('SUCCESS: Trainer client list includes paired client.');
    print('=== ALL QR PAIRING INTEGRATION TESTS PASSED ===');
  });
}
