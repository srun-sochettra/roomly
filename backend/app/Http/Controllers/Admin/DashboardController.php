<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\User;

class DashboardController extends Controller
{
    public function __invoke()
    {
        Booking::expireStale();

        return view('admin.dashboard', [
            'stats' => [
                'pending' => Booking::where('status', 'pending')->count(),
                'today' => Booking::where('status', 'approved')->whereDate('start_at', today())->count(),
                'rooms' => Room::where('is_active', true)->count(),
                'students' => User::where('role', 'student')->count(),
            ],
            'pending' => Booking::with(['room', 'user'])->where('status', 'pending')
                ->orderBy('start_at')->limit(6)->get(),
            'todaySchedule' => Booking::with(['room', 'user'])->where('status', 'approved')
                ->whereDate('start_at', today())->orderBy('start_at')->get(),
        ]);
    }
}
