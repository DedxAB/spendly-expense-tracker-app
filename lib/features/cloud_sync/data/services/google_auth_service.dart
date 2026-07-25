import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spendly/features/cloud_sync/data/services/cloud_sync_exceptions.dart';

class GoogleAccount {
  const GoogleAccount({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;
}

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const <String>[
              'https://www.googleapis.com/auth/drive.appdata',
            ],
          );

  final GoogleSignIn _googleSignIn;

  Future<GoogleAccount> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw const CloudSyncAuthException('Sign in cancelled by user.');
    }
    return _toGoogleAccount(account);
  }

  Future<GoogleAccount?> getSignedInAccount({required bool silentOnly}) async {
    final current = _googleSignIn.currentUser;
    if (current != null) {
      return _toGoogleAccount(current);
    }

    final silent = await _signInSilently();
    if (silent != null) {
      return _toGoogleAccount(silent);
    }

    if (silentOnly) {
      return null;
    }

    final interactive = await _googleSignIn.signIn();
    if (interactive == null) {
      return null;
    }
    return _toGoogleAccount(interactive);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }

  Future<AccessToken> accessToken({required bool interactiveIfNeeded}) async {
    final account = await _resolveAccount(
      interactiveIfNeeded: interactiveIfNeeded,
    );
    final authHeaders = await account.authHeaders;
    final token = _extractBearerToken(authHeaders);
    if (token == null || token.isEmpty) {
      throw const CloudSyncAuthException('Could not retrieve access token.');
    }

    // Tokens are managed by Google Sign-In. Expiry here is a local hint.
    return AccessToken(
      'Bearer',
      token,
      DateTime.now().add(const Duration(minutes: 45)),
    );
  }

  Future<http.Client> authenticatedClient({
    required bool interactiveIfNeeded,
  }) async {
    final account = await _resolveAccount(
      interactiveIfNeeded: interactiveIfNeeded,
    );
    return _GoogleAuthHttpClient(headerProvider: () => account.authHeaders);
  }

  Future<GoogleSignInAccount?> _signInSilently() async {
    try {
      return await _googleSignIn.signInSilently().timeout(
        const Duration(seconds: 4),
      );
    } catch (_) {
      return _googleSignIn.currentUser;
    }
  }

  Future<GoogleSignInAccount> _resolveAccount({
    required bool interactiveIfNeeded,
  }) async {
    final current = _googleSignIn.currentUser;
    if (current != null) {
      return current;
    }

    final silent = await _signInSilently();
    if (silent != null) {
      return silent;
    }

    if (!interactiveIfNeeded) {
      throw const CloudSyncAuthException(
        'User is not signed in to Google account.',
      );
    }

    final interactive = await _googleSignIn.signIn();
    if (interactive == null) {
      throw const CloudSyncAuthException('Sign in cancelled by user.');
    }
    return interactive;
  }

  GoogleAccount _toGoogleAccount(GoogleSignInAccount account) {
    final displayName = (account.displayName ?? '').trim();
    return GoogleAccount(
      name: displayName.isEmpty ? 'User' : displayName,
      email: account.email.trim(),
      photoUrl: account.photoUrl,
    );
  }

  String? _extractBearerToken(Map<String, String> headers) {
    final header =
        headers['Authorization'] ??
        headers['authorization'] ??
        headers['AUTHORIZATION'];
    if (header == null) {
      return null;
    }
    const prefix = 'Bearer ';
    if (header.startsWith(prefix)) {
      return header.substring(prefix.length);
    }
    return null;
  }
}

class _GoogleAuthHttpClient extends http.BaseClient {
  _GoogleAuthHttpClient({required this.headerProvider});

  final Future<Map<String, String>> Function() headerProvider;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await headerProvider();
    request.headers.addAll(headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});
