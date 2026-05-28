import 'package:dio/dio.dart';

class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  factory NetworkException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException('The connection timed out.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection available.');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return NetworkException('Request failed with status code $statusCode.');
    }

    return const NetworkException(
      'Something went wrong while loading recipes.',
    );
  }

  @override
  String toString() => message;
}
