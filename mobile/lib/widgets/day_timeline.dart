import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';
import '../theme.dart';

/// One day from 07:00 to 21:00. Taken slots are drawn as blocks; tapping a free hour starts a booking there.
class DayTimeline extends StatelessWidget {
  const DayTimeline({super.key, required this.day, required this.slots, required this.onPickHour});

  final DateTime day;
  final List<Slot> slots;
  final void Function(int hour) onPickHour;

  static const startHour = 7;
  static const endHour = 21;
  static const hourHeight = 56.0;
  static const labelWidth = 52.0;

  DateTime _at(int hour) => DateTime(day.year, day.month, day.day, hour);

  double _y(DateTime t) {
    final minutes = t.difference(_at(startHour)).inMinutes.clamp(0, (endHour - startHour) * 60);
    return minutes / 60 * hourHeight;
  }

  bool _hourIsFree(int hour) {
    final from = _at(hour), to = _at(hour + 1);
    if (!from.isAfter(DateTime.now())) return false;
    return !slots.any((s) => s.start.isBefore(to) && s.end.isAfter(from));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(now, day);
    final time = DateFormat('HH:mm');

    return SizedBox(
      height: (endHour - startHour) * hourHeight + 8,
      child: Stack(children: [
        for (var h = startHour; h < endHour; h++)
          Positioned(
            top: (h - startHour) * hourHeight,
            left: 0,
            right: 0,
            height: hourHeight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: labelWidth,
                child: Text('${h.toString().padLeft(2, '0')}:00',
                    style: TextStyle(fontSize: 12, color: c.muted, fontFeatures: const [FontFeature.tabularFigures()])),
              ),
              Expanded(
                child: _hourIsFree(h)
                    ? Semantics(
                        button: true,
                        label: 'Book from ${h.toString().padLeft(2, '0')}:00',
                        child: InkWell(
                          onTap: () => onPickHour(h),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.add_rounded, size: 18, color: c.muted.withValues(alpha: 0.6)),
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: _at(h + 1).isBefore(now) ? c.surfaceAlt : null,
                          border: Border(top: BorderSide(color: c.line)),
                        ),
                      ),
              ),
            ]),
          ),
        for (final s in slots)
          if (_y(s.end) > _y(s.start))
            Positioned(
              top: _y(s.start) + 1,
              height: _y(s.end) - _y(s.start) - 2,
              left: labelWidth,
              right: 0,
              child: _SlotBlock(slot: s, label: '${time.format(s.start)} – ${time.format(s.end)}'),
            ),
        if (isToday && now.hour >= startHour && now.hour < endHour)
          Positioned(
            top: _y(now) - 4,
            left: labelWidth - 5,
            right: 0,
            child: IgnorePointer(
              child: Row(children: [
                Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle)),
                Expanded(child: Container(height: 2, color: const Color(0xFFE11D48))),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _SlotBlock extends StatelessWidget {
  const _SlotBlock({required this.slot, required this.label});
  final Slot slot;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final approved = slot.status == 'approved';
    final (Color bg, Color fg) = slot.mine
        ? (c.brand, c.onBrand)
        : approved
            ? (c.brandSoft, c.brandStrong)
            : (c.amberBg, c.amberFg);
    final title = slot.mine ? 'Your booking' : (approved ? 'Booked' : 'On hold');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: fg, width: 3)),
      ),
      child: ClipRect(
        child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13)),
          Text(label, style: TextStyle(color: fg.withValues(alpha: 0.85), fontSize: 12)),
        ]),
      ),
    );
  }
}
