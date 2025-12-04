import 'dart:convert';

import 'package:dio/dio.dart';

import '../log_capture.dart';
import '../models/log_entry.dart';

/// Dio interceptor for logging API requests and responses to in_app_logview.
///
/// This interceptor captures all HTTP requests and responses made through Dio
/// and displays them in the in-app log viewer with detailed information.
///
/// **Usage:**
///
/// ```dart
/// import 'package:dio/dio.dart';
/// import 'package:in_app_logview/in_app_logview.dart';
///
/// final dio = Dio();
/// dio.interceptors.add(InAppLogDioInterceptor());
///
/// // Now all API calls will be logged
/// final response = await dio.get('https://api.example.com/data');
/// ```
///
/// **Customization:**
///
/// ```dart
/// dio.interceptors.add(
///   InAppLogDioInterceptor(
///     logRequest: true,
///     logResponse: true,
///     logError: true,
///     logRequestHeaders: false, // Hide sensitive headers
///     logResponseHeaders: false,
///   ),
/// );
/// ```
class InAppLogDioInterceptor extends Interceptor {
  /// Whether to log request details.
  final bool logRequest;

  /// Whether to log response details.
  final bool logResponse;

  /// Whether to log error details.
  final bool logError;

  /// Whether to include request headers in logs.
  final bool logRequestHeaders;

  /// Whether to include response headers in logs.
  final bool logResponseHeaders;

  /// Whether to include request body in logs.
  final bool logRequestBody;

  /// Whether to include response body in logs.
  final bool logResponseBody;

  /// Custom tag for API logs (default: 'API').
  final String tag;

  /// Creates a new [InAppLogDioInterceptor].
  ///
  /// All logging options are enabled by default.
  InAppLogDioInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logRequestHeaders = true,
    this.logResponseHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.tag = 'API',
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      _logError(err);
    }
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('┌─ Request ──────────────────────────────────────────────');
    buffer.writeln('│ ${options.method} ${options.uri}');

    if (logRequestHeaders && options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    if (logRequestBody && options.data != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatData(options.data);
      for (final line in bodyStr.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.writeln('└───────────────────────────────────────────────────────');

    LogCapture().addLogFromString(
      buffer.toString(),
      level: LogLevel.info,
      tag: tag,
    );
  }

  void _logResponse(Response response) {
    final buffer = StringBuffer();
    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    buffer.writeln('┌─ Response ─────────────────────────────────────────────');
    buffer.writeln(
        '│ ${response.requestOptions.method} ${response.requestOptions.uri}');
    buffer.writeln('│ Status: $statusCode ${response.statusMessage ?? ''}');

    if (logResponseHeaders && response.headers.map.isNotEmpty) {
      buffer.writeln('│ Headers:');
      response.headers.map.forEach((key, values) {
        buffer.writeln('│   $key: ${values.join(', ')}');
      });
    }

    if (logResponseBody && response.data != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatData(response.data);
      for (final line in bodyStr.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    buffer.writeln('└───────────────────────────────────────────────────────');

    LogCapture().addLogFromString(
      buffer.toString(),
      level: isSuccess ? LogLevel.info : LogLevel.warning,
      tag: tag,
    );
  }

  void _logError(DioException error) {
    final buffer = StringBuffer();
    buffer.writeln('┌─ Error ────────────────────────────────────────────────');
    buffer.writeln(
        '│ ${error.requestOptions.method} ${error.requestOptions.uri}');
    buffer.writeln('│ Type: ${error.type}');

    if (error.response != null) {
      final response = error.response!;
      buffer.writeln(
          '│ Status: ${response.statusCode} ${response.statusMessage ?? ''}');

      if (logResponseBody && response.data != null) {
        buffer.writeln('│ Error Body:');
        final bodyStr = _formatData(response.data);
        for (final line in bodyStr.split('\n')) {
          buffer.writeln('│   $line');
        }
      }
    } else {
      buffer.writeln('│ Message: ${error.message}');
    }

    buffer.writeln('└───────────────────────────────────────────────────────');

    LogCapture().addLogFromString(
      buffer.toString(),
      level: LogLevel.error,
      tag: tag,
    );
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';

    // Use JsonEncoder with indentation for pretty printing
    const encoder = JsonEncoder.withIndent('  ');

    // If data is a Map or List, convert to pretty JSON
    if (data is Map || data is List) {
      try {
        return encoder.convert(data);
      } catch (e) {
        // If conversion fails, fall back to toString
        return data.toString();
      }
    }

    // If data is a String, try to parse and format as JSON
    if (data is String) {
      final trimmed = data.trim();
      // Check if it looks like JSON
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          // Parse the JSON string
          final decoded = jsonDecode(trimmed);
          // Re-encode with pretty printing
          return encoder.convert(decoded);
        } catch (e) {
          // If parsing fails, return original string
          return data;
        }
      }
      // Not JSON, return as-is
      return data;
    }

    // For other types, convert to string
    return data.toString();
  }
}
