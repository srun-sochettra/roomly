<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Booking extends Model
{
    /** Statuses that still hold the room. */
    public const ACTIVE = ['pending', 'approved'];

    public const STATUSES = ['pending', 'approved', 'rejected', 'cancelled', 'expired'];

    protected $fillable = ['user_id', 'room_id', 'start_at', 'end_at', 'attendees', 'purpose', 'status', 'admin_note'];

    protected function casts(): array
    {
        return ['start_at' => 'datetime', 'end_at' => 'datetime', 'attendees' => 'integer'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    /**
     * Two time ranges overlap when A starts before B ends AND A ends after B starts.
     * Back-to-back bookings (09:00-10:00 then 10:00-11:00) are allowed.
     */
    public function scopeOverlapping(Builder $query, int $roomId, $start, $end, array $statuses = self::ACTIVE): Builder
    {
        return $query->where('room_id', $roomId)
            ->whereIn('status', $statuses)
            ->where('start_at', '<', $end)
            ->where('end_at', '>', $start);
    }

    /**
     * Pending requests nobody reviewed before their start time become "expired".
     * Runs every minute via the scheduler, and also before bookings are listed,
     * so the demo stays correct even when the scheduler is not running.
     */
    public static function expireStale(): int
    {
        return static::where('status', 'pending')
            ->where('start_at', '<=', now())
            ->update(['status' => 'expired', 'admin_note' => 'Not reviewed before the start time.']);
    }
}
