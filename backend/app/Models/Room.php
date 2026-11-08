<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Room extends Model
{
    public const TYPES = ['Study room', 'Meeting room', 'Lab', 'Hall'];

    protected $fillable = ['name', 'type', 'capacity', 'location', 'image_url', 'description', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'capacity' => 'integer'];
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    /** The booking holding the room right now, if any. */
    public function currentBooking(): HasOne
    {
        return $this->hasOne(Booking::class)
            ->whereIn('status', Booking::ACTIVE)
            ->where('start_at', '<=', now())
            ->where('end_at', '>', now());
    }

    /** The next booking later today, used for "Free until 14:00". */
    public function nextBookingToday(): HasOne
    {
        return $this->hasOne(Booking::class)
            ->whereIn('status', Booking::ACTIVE)
            ->where('start_at', '>', now())
            ->where('start_at', '<=', today()->endOfDay())
            ->orderBy('start_at');
    }
}
