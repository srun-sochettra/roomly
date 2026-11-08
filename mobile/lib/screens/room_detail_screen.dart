import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../state/auth_provider.dart';
import '../theme.dart';
import '../widgets/day_timeline.dart';
import '../widgets/state_views.dart';
import 'booking_sheet.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.room});
  final Room room;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  static const _days = 14;
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  late Future<List<Slot>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<AuthProvider>().api.schedule(widget.room.id, _day);
  }

  void _selectDay(DateTime d) => setState(() {
        _day = d;
        _load();
      });

  Future<void> _book({DateTime? day, int? hour}) async {
    final booked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => BookingSheet(room: widget.room, initialDate: day, initialHour: hour),
    );
    if (booked == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent. Track it under My bookings.')),
      );
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final room = widget.room;
    final text = Theme.of(context).textTheme;
    final today = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              Hero(tag: 'room-${room.id}', child: RoomImage(room.imageUrl)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent, Colors.black26],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(room.type.toUpperCase(),
                  style: TextStyle(color: c.brand, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text(room.name, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _Fact(icon: Icons.groups_rounded, label: 'Up to ${room.capacity} people'),
                if (room.location != null) _Fact(icon: Icons.place_outlined, label: room.location!),
              ]),
              if (room.description != null) ...[
                const SizedBox(height: 18),
                Text(room.description!, style: text.bodyLarge?.copyWith(color: c.muted, height: 1.55)),
              ],
              const SizedBox(height: 28),
              Text('Availability', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Tap a free hour to book it.', style: TextStyle(color: c.muted)),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              itemCount: _days,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = today.add(Duration(days: i));
                final selected = DateUtils.isSameDay(d, _day);
                return Semantics(
                  selected: selected,
                  button: true,
                  label: DateFormat('EEEE d MMMM').format(d),
                  child: InkWell(
                    onTap: () => _selectDay(d),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 54,
                      decoration: BoxDecoration(
                        color: selected ? c.ink : c.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selected ? c.ink : c.line),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(i == 0 ? 'Today' : DateFormat('EEE').format(d),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? c.background.withValues(alpha: 0.75) : c.muted)),
                        const SizedBox(height: 2),
                        Text('${d.day}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: selected ? c.background : c.ink)),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverToBoxAdapter(
            child: FutureBuilder<List<Slot>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
                }
                if (snap.hasError) return ErrorView(error: snap.error, onRetry: () => setState(_load));
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _Legend(),
                  const SizedBox(height: 14),
                  DayTimeline(day: _day, slots: snap.data!, onPickHour: (h) => _book(day: _day, hour: h)),
                ]);
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: () => _book(day: _day.isAfter(today) ? _day : null),
            icon: const Icon(Icons.event_available_rounded),
            label: const Text('Book this room'),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget item(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: c.muted, fontWeight: FontWeight.w600)),
        ]);
    return Wrap(spacing: 16, runSpacing: 6, children: [
      item(c.brand, 'Yours'),
      item(c.brandSoft, 'Booked'),
      item(c.amberBg, 'On hold'),
    ]);
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.line)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: c.brand),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
