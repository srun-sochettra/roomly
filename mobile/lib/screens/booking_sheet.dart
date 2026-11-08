import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../services/api_service.dart';
import '../state/auth_provider.dart';
import '../theme.dart';

class BookingSheet extends StatefulWidget {
  const BookingSheet({super.key, required this.room, this.initialDate, this.initialHour});
  final Room room;

  /// Prefilled from a tap on the timeline.
  final DateTime? initialDate;
  final int? initialHour;

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  int _people = 1;
  final _purpose = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(widget.initialDate ?? DateTime.now().add(const Duration(days: 1)));
    final h = widget.initialHour ?? 9;
    _start = TimeOfDay(hour: h, minute: 0);
    _end = TimeOfDay(hour: h < 22 ? h + 1 : 23, minute: h < 22 ? 0 : 59);
  }

  DateTime get _startAt => DateTime(_date.year, _date.month, _date.day, _start.hour, _start.minute);
  DateTime get _endAt => DateTime(_date.year, _date.month, _date.day, _end.hour, _end.minute);

  @override
  void dispose() {
    _purpose.dispose();
    super.dispose();
  }

  String? _validate() {
    if (!_startAt.isAfter(DateTime.now())) return 'Pick a start time in the future.';
    if (!_endAt.isAfter(_startAt)) return 'End time must be after the start time.';
    if (_endAt.difference(_startAt).inMinutes > 240) return 'A booking can last at most 4 hours.';
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _start : _end);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (!_endAt.isAfter(_startAt)) _end = TimeOfDay(hour: picked.hour < 23 ? picked.hour + 1 : 23, minute: picked.minute);
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().api.createBooking(
            roomId: widget.room.id,
            start: _startAt,
            end: _endAt,
            attendees: _people,
            purpose: _purpose.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final mins = _endAt.difference(_startAt).inMinutes;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text('Book ${widget.room.name}', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('An admin will review your request.', style: text.bodyMedium?.copyWith(color: c.muted)),
          const SizedBox(height: 20),
          _PickerTile(icon: Icons.calendar_today_rounded, label: 'Date', value: DateFormat('EEE, d MMM yyyy').format(_date), onTap: _pickDate),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _PickerTile(icon: Icons.login_rounded, label: 'From', value: _start.format(context), onTap: () => _pickTime(true))),
            const SizedBox(width: 10),
            Expanded(child: _PickerTile(icon: Icons.logout_rounded, label: 'To', value: _end.format(context), onTap: () => _pickTime(false))),
          ]),
          if (mins > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text('${mins ~/ 60}h ${mins % 60 == 0 ? '' : '${mins % 60}m'}'.trim(),
                  style: TextStyle(color: c.brand, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 18),
          Row(children: [
            const Expanded(child: Text('People', style: TextStyle(fontWeight: FontWeight.w700))),
            IconButton.outlined(
              tooltip: 'Fewer people',
              onPressed: _people > 1 ? () => setState(() => _people--) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 56,
              child: Text('$_people', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            IconButton.outlined(
              tooltip: 'More people',
              onPressed: _people < widget.room.capacity ? () => setState(() => _people++) : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ]),
          Text('Max ${widget.room.capacity}', textAlign: TextAlign.end, style: TextStyle(color: c.muted, fontSize: 12)),
          const SizedBox(height: 14),
          TextField(
            controller: _purpose,
            maxLength: 255,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What’s it for? (optional)', counterText: ''),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: c.danger, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: c.onBrand))
                : const Text('Send request'),
          ),
        ]),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(icon, size: 20, color: c.brand),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(color: c.muted, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
