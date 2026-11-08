import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../services/api_service.dart';
import '../state/auth_provider.dart';
import '../theme.dart';
import '../widgets/state_views.dart';
import '../widgets/status_chip.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _future;
  bool _upcoming = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<AuthProvider>().api.myBookings();
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {}
  }

  Future<void> _cancel(Booking b) async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text('${b.room?.name ?? 'This room'} on ${DateFormat('EEE d MMM, HH:mm').format(b.start)} will be released for others.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep booking')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.danger, foregroundColor: c.surface, minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthProvider>().api.cancelBooking(b.id);
      messenger.showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      _refresh();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Text('My bookings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [ButtonSegment(value: true, label: Text('Upcoming')), ButtonSegment(value: false, label: Text('Past'))],
            selected: {_upcoming},
            onSelectionChanged: (s) => setState(() => _upcoming = s.first),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<Booking>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                if (snap.hasError) return ListView(children: [ErrorView(error: snap.error, onRetry: _refresh)]);

                final list = snap.data!.where((b) => b.isUpcoming == _upcoming).toList();
                if (_upcoming) list.sort((a, b) => a.start.compareTo(b.start));
                if (list.isEmpty) {
                  return ListView(children: [
                    MessageView(
                      icon: Icons.event_busy_rounded,
                      title: _upcoming ? 'Nothing booked yet' : 'No past bookings',
                      message: _upcoming ? 'Find a room on the Rooms tab and send a request.' : null,
                    ),
                  ]);
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _BookingCard(list[i], onCancel: () => _cancel(list[i])),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.booking, {required this.onCancel});
  final Booking booking;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = booking;
    final time = DateFormat('HH:mm');
    return Container(
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.line)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 64, height: 64, child: RoomImage(b.room?.imageUrl))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(b.room?.name ?? 'Room', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                  StatusChip(b.status),
                ]),
                const SizedBox(height: 6),
                Text(DateFormat('EEE, d MMM').format(b.start), style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${time.format(b.start)} – ${time.format(b.end)} · ${b.attendees} ${b.attendees == 1 ? 'person' : 'people'}',
                    style: TextStyle(color: c.muted)),
                if (b.purpose != null) ...[
                  const SizedBox(height: 4),
                  Text(b.purpose!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.muted)),
                ],
              ]),
            ),
          ]),
        ),
        if (b.adminNote != null)
          Container(
            width: double.infinity,
            color: c.surfaceAlt,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text('Admin: ${b.adminNote}', style: TextStyle(fontSize: 13, color: c.muted)),
          ),
        if (b.canCancel)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: c.danger),
              child: const Text('Cancel booking'),
            ),
          ),
      ]),
    );
  }
}
