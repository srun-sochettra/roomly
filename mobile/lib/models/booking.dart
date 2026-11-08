import 'room.dart';

enum BookingStatus { pending, approved, rejected, cancelled, expired }

class Booking {
  final int id;
  final BookingStatus status;
  final DateTime start;
  final DateTime end;
  final int attendees;
  final String? purpose;
  final String? adminNote;
  final Room? room;

  const Booking({
    required this.id,
    required this.status,
    required this.start,
    required this.end,
    required this.attendees,
    this.purpose,
    this.adminNote,
    this.room,
  });

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as int,
        status: BookingStatus.values.asNameMap()[j['status']] ?? BookingStatus.cancelled,
        start: DateTime.parse(j['start_at'] as String).toLocal(),
        end: DateTime.parse(j['end_at'] as String).toLocal(),
        attendees: (j['attendees'] as num).toInt(),
        purpose: j['purpose'] as String?,
        adminNote: j['admin_note'] as String?,
        room: j['room'] is Map<String, dynamic> ? Room.fromJson(j['room'] as Map<String, dynamic>) : null,
      );

  bool get isUpcoming => end.isAfter(DateTime.now());
  bool get canCancel =>
      (status == BookingStatus.pending || status == BookingStatus.approved) && start.isAfter(DateTime.now());
}
