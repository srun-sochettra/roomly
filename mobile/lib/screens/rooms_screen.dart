import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme.dart';
import '../widgets/state_views.dart';
import 'room_detail_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  static const _types = ['Study room', 'Meeting room', 'Lab', 'Hall'];

  late Future<List<Room>> _future;
  String _search = '';
  String? _type;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _load() {
    _future = context.read<AuthProvider>().api.rooms(search: _search, type: _type);
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {}
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value.trim();
      setState(_load);
    });
  }

  Future<void> _open(Room room) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<AuthProvider>().user;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text('Hi, ${user?.name.split(' ').first ?? 'there'}', style: text.bodyLarge?.copyWith(color: c.muted)),
                    ),
                    IconButton.outlined(
                      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                      style: IconButton.styleFrom(side: BorderSide(color: c.line), backgroundColor: c.surface),
                      onPressed: () => context.read<ThemeProvider>().toggle(Theme.of(context).brightness),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => RotationTransition(
                          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            key: ValueKey(isDark), color: isDark ? const Color(0xFFFCD34D) : c.ink),
                      ),
                    ),
                  ]),
                  Text('Where are we working today?', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: _onSearch,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(hintText: 'Search rooms or buildings', prefixIcon: Icon(Icons.search_rounded)),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  children: [null, ..._types].map((t) {
                    final selected = _type == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t ?? 'All'),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: c.ink,
                        backgroundColor: c.surface,
                        side: BorderSide(color: selected ? c.ink : c.line),
                        labelStyle: TextStyle(color: selected ? c.background : c.ink, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        onSelected: (_) => setState(() {
                          _type = t;
                          _load();
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            FutureBuilder<List<Room>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()));
                }
                if (snap.hasError) {
                  return SliverToBoxAdapter(child: ErrorView(error: snap.error, onRetry: _refresh));
                }
                final rooms = snap.data!;
                if (rooms.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: MessageView(icon: Icons.search_off_rounded, title: 'No rooms found', message: 'Try a different search or filter.'),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _RoomCard(rooms[i], onTap: () => _open(rooms[i])),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard(this.room, {required this.onTap});
  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              Hero(tag: 'room-${room.id}', child: RoomImage(room.imageUrl)),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(99)),
                  child: Text(room.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.ink)),
                ),
              ),
              if (room.busyNow != null) Positioned(right: 12, top: 12, child: _AvailabilityBadge(room)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(room.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  if (room.location != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.place_outlined, size: 16, color: c.muted),
                      const SizedBox(width: 4),
                      Flexible(child: Text(room.location!, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.muted))),
                    ]),
                  ],
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: c.brandSoft, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.groups_rounded, size: 18, color: c.brandStrong),
                  const SizedBox(width: 6),
                  Text('${room.capacity}', style: TextStyle(fontWeight: FontWeight.w800, color: c.brandStrong)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// "Free now", "Free until 14:00" or "Busy until 16:00".
class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge(this.room);
  final Room room;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final busy = room.busyNow!;
    final until = room.until == null ? null : DateFormat('HH:mm').format(room.until!);
    final label = busy ? 'Busy until $until' : (until == null ? 'Free now' : 'Free until $until');
    final (Color bg, Color fg) = busy ? (c.amberBg, c.amberFg) : (c.greenBg, c.greenFg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}
