enum AppErrorType {
  network,
  authentication,
  permissionDenied,
  invalidEmailDomain,
  collegeNotFound,
  verificationPending,
  accountSuspended,
  validation,
  unknown,
}

class AppError implements Exception {
  final String title;
  final String message;
  final AppErrorType type;
  final dynamic originalError;

  const AppError({
    required this.title,
    required this.message,
    this.type = AppErrorType.unknown,
    this.originalError,
  });

  factory AppError.fromException(dynamic error) {
    if (error is AppError) return error;

    final errStr = error.toString().toLowerCase();

    if (errStr.contains('network') || errStr.contains('socket') || errStr.contains('connection')) {
      return const AppError(
        title: 'Connection Issue',
        message: 'Unable to reach Universtree servers. Please check your internet connection.',
        type: AppErrorType.network,
      );
    } else if (errStr.contains('permission-denied') || errStr.contains('unauthorized')) {
      return const AppError(
        title: 'Access Denied',
        message: 'You do not have permission to perform this action or view this institutional data.',
        type: AppErrorType.permissionDenied,
      );
    } else if (errStr.contains('invalid-email') || errStr.contains('user-not-found') || errStr.contains('wrong-password')) {
      return const AppError(
        title: 'Authentication Failed',
        message: 'Invalid credentials or institutional email address. Please check and try again.',
        type: AppErrorType.authentication,
      );
    }

    return AppError(
      title: 'Unexpected Error',
      message: 'Something went wrong. Please try again later.',
      type: AppErrorType.unknown,
      originalError: error,
    );
  }

  @override
  String toString() => '$title: $message';
}
