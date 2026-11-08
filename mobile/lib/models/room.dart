class Room {
  final int id;
  final String name;
  final String type;
  final int capacity;
  final String? location;
  final String? imageUrl;
  final String? description;

  /// Only present on the rooms list. busyNow = someone holds the room right now.
  /// availableUntil / busyUntil: null busyNow means unknown; null `until` while free means free for the rest of today.
  final bool? busyNow;
  final DateTime? until;

  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    this.location,
    this.imageUrl,
    this.description,
    this.busyNow,
    this.until,
  });

  factory Room.fromJson(Map<String, dynamic> j) {
    final availability = j['availability'] as Map<String, dynamic>?;
    final until = availability?['until'] as String?;
    return Room(
      id: j['id'] as int,
      name: j['name'] as String,
      type: j['type'] as String,
      capacity: (j['capacity'] as num).toInt(),
      location: j['location'] as String?,
      imageUrl: j['image_url'] as String?,
      description: j['description'] as String?,
      busyNow: availability == null ? null : availability['state'] == 'busy',
      until: until == null ? null : DateTime.parse(until).toLocal(),
    );
  }
}

/// A taken time slot shown on the room timeline.
class Slot {
  final DateTime start;
  final DateTime end;
  final String status;
  final bool mine;

  const Slot(this.start, this.end, this.status, {this.mine = false});

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        DateTime.parse(j['start_at'] as String).toLocal(),
        DateTime.parse(j['end_at'] as String).toLocal(),
        j['status'] as String,
        mine: j['mine'] == true,
      );
}
