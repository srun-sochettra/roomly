import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg, IconData icon, String label) = switch (status) {
      BookingStatus.pending => (c.amberBg, c.amberFg, Icons.schedule_rounded, 'Pending'),
      BookingStatus.approved => (c.greenBg, c.greenFg, Icons.check_circle_rounded, 'Approved'),
      BookingStatus.rejected => (c.roseBg, c.roseFg, Icons.cancel_rounded, 'Rejected'),
      BookingStatus.cancelled => (c.slateBg, c.slateFg, Icons.block_rounded, 'Cancelled'),
      BookingStatus.expired => (c.slateBg, c.slateFg, Icons.hourglass_disabled_rounded, 'Expired'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
