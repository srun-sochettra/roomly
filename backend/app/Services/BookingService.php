<?php

namespace App\Services;

use App\Exceptions\BookingRuleException;
use App\Models\Booking;
use App\Models\Room;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/** All booking rules live here, so the mobile API and the web admin enforce the same rules. */
class BookingService
{
    public function create(User $user, array $data): Booking
    {
        $start = Carbon::parse($data['start_at']);
        $end = Carbon::parse($data['end_at']);

        return DB::transaction(function () use ($user, $data, $start, $end) {
            // Lock the room row so two simultaneous requests cannot both pass the overlap check.
            Room::whereKey($data['room_id'])->lockForUpdate()->first();

            if (Booking::overlapping($data['room_id'], $start, $end)->exists()) {
                throw new BookingRuleException('This room is already booked for that time. Try another slot.');
            }

            return $user->bookings()->create([
                ...$data,
                'start_at' => $start,
                'end_at' => $end,
                'status' => 'pending',
            ]);
        });
    }

    public function approve(Booking $booking, ?string $note = null): Booking
    {
        $this->ensurePending($booking);

        return DB::transaction(function () use ($booking, $note) {
            Room::whereKey($booking->room_id)->lockForUpdate()->first();

            $clash = Booking::overlapping($booking->room_id, $booking->start_at, $booking->end_at, ['approved'])
                ->whereKeyNot($booking->id)
                ->exists();

            if ($clash) {
                throw new BookingRuleException('Another approved booking already holds this slot.');
            }

            $booking->update(['status' => 'approved', 'admin_note' => $note]);

            return $booking;
        });
    }

    public function reject(Booking $booking, ?string $note = null): Booking
    {
        $this->ensurePending($booking);
        $booking->update(['status' => 'rejected', 'admin_note' => $note]);

        return $booking;
    }

    /** Student cancels their own booking. */
    public function cancel(Booking $booking): Booking
    {
        $this->ensureCancellable($booking);
        $booking->update(['status' => 'cancelled']);

        return $booking;
    }

    /** Admin cancels a booking, e.g. an approval made by mistake. The reason is shown in the app. */
    public function adminCancel(Booking $booking, ?string $note = null): Booking
    {
        $this->ensureCancellable($booking);
        $booking->update(['status' => 'cancelled', 'admin_note' => $note ?: 'Cancelled by an admin.']);

        return $booking;
    }

    private function ensureCancellable(Booking $booking): void
    {
        if (! in_array($booking->status, Booking::ACTIVE, true)) {
            throw new BookingRuleException("A {$booking->status} booking cannot be cancelled.", 422);
        }
        if ($booking->start_at->isPast()) {
            throw new BookingRuleException('Bookings that have already started cannot be cancelled.', 422);
        }
    }

    private function ensurePending(Booking $booking): void
    {
        if ($booking->status !== 'pending') {
            throw new BookingRuleException("This booking is already {$booking->status}.", 422);
        }
    }
}
