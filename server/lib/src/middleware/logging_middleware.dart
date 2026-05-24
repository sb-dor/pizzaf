import 'package:shelf/shelf.dart';

/// Logging middleware that logs request method, path, status, and duration.
Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;
      final status = response.statusCode;
      final method = request.method;
      final path = request.requestedUri.path;

      // Color-code status: green for 2xx, yellow for 4xx, red for 5xx
      final statusColor = switch (status) {
        >= 200 && < 300 => '\x1b[32m', // green
        >= 400 && < 500 => '\x1b[33m', // yellow
        _ => '\x1b[31m', // red
      };
      const reset = '\x1b[0m';

      print('$method $path → $statusColor$status$reset (${duration}ms)');

      return response;
    };
  };
}
