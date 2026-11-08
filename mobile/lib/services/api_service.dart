import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);

  @override
  String toString() => message;
}

class ApiService {
  ApiService({this.onUnauthorized});

  String? token;
  final void Function()? onUnauthorized;
  final _client = http.Client();
  static final _wireFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<dynamic> _send(String method, String path, {Map<String, dynamic>? body, Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(await _client.send(request).timeout(const Duration(seconds: 15)));
    } on TimeoutException {
      throw const ApiException('The server took too long to respond. Try again.');
    } catch (_) {
      throw const ApiException('Can’t reach the server. Check your connection and the API URL.');
    }

    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    if (res.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(_errorMessage(data), res.statusCode);
  }

  /// Laravel validation errors look like {message, errors: {field: [msg]}}. Show the first field message.
  String _errorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }

  // Auth
  Future<(String, AppUser)> login(String email, String password) =>
      _auth('/login', {'email': email, 'password': password});

  Future<(String, AppUser)> register(String name, String email, String password) =>
      _auth('/register', {'name': name, 'email': email, 'password': password});

  Future<(String, AppUser)> _auth(String path, Map<String, dynamic> body) async {
    final data = await _send('POST', path, body: body) as Map<String, dynamic>;
    return (data['token'] as String, AppUser.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<AppUser> me() async => AppUser.fromJson((await _send('GET', '/me'))['data'] as Map<String, dynamic>);

  Future<void> logout() => _send('POST', '/logout');

  // Rooms
  Future<List<Room>> rooms({String? search, String? type}) async {
    final data = await _send('GET', '/rooms', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
    });
    return (data['data'] as List).map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Taken slots for one day, for the room timeline.
  Future<List<Slot>> schedule(int roomId, DateTime day) async {
    final data = await _send('GET', '/rooms/$roomId/schedule', query: {'date': DateFormat('yyyy-MM-dd').format(day)});
    return (data['data'] as List).map((e) => Slot.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Bookings
  Future<List<Booking>> myBookings() async {
    final data = await _send('GET', '/bookings');
    return (data['data'] as List).map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Booking> createBooking({
    required int roomId,
    required DateTime start,
    required DateTime end,
    required int attendees,
    String? purpose,
  }) async {
    final data = await _send('POST', '/bookings', body: {
      'room_id': roomId,
      'start_at': _wireFormat.format(start),
      'end_at': _wireFormat.format(end),
      'attendees': attendees,
      if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
    });
    return Booking.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> cancelBooking(int id) => _send('PATCH', '/bookings/$id/cancel');
}
