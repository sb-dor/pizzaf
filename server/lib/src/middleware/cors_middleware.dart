import 'dart:io';

import 'package:shelf/shelf.dart';

/// CORS middleware that adds Access-Control-Allow-* headers
/// and handles preflight OPTIONS requests.
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Handle preflight OPTIONS request
      if (request.method == 'OPTIONS') {
        return Response(HttpStatus.ok, headers: _corsHeaders);
      }

      // Add CORS headers to the actual response
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};
