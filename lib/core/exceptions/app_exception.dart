sealed class AppException implements Exception {
  final String message;
  final String? code;
  final String userMessage;

  const AppException(this.message, {this.code, required this.userMessage});

  @override
  String toString() => 'AppException: [$code] $message';
}

class AuthException extends AppException {
  AuthException(String message, [String? code]) 
    : super(message, code: code, userMessage: _mapCodeToUserMessage(code));

  static String _mapCodeToUserMessage(String? code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger one.';
      case 'network-request-failed':
        return 'Connection failed. Please check your internet.';
      case 'channel-error':
        return 'Please fill in all fields.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class DatabaseException extends AppException {
  const DatabaseException(String message, [String? code]) 
    : super(message, code: code, userMessage: 'Something went wrong while saving your data.');
}

class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) 
    : super(message, code: code, userMessage: 'We couldn\'t connect to the internet.');
}

class UnknownException extends AppException {
  const UnknownException([String? message]) 
    : super(message ?? 'An unexpected error occurred', userMessage: 'Something went wrong. Please try again.');
}
