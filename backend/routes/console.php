<?php

use App\Models\Booking;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('bookings:expire', function () {
    $count = Booking::expireStale();
    $this->info("Expired {$count} stale pending booking(s).");
})->purpose('Mark pending bookings that were never reviewed before their start time as expired');

Schedule::command('bookings:expire')->everyMinute();
