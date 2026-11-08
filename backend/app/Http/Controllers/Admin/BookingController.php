<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Services\BookingService;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function __construct(private BookingService $service) {}

    public function index(Request $request)
    {
        Booking::expireStale();
        $status = $request->query('status');

        $bookings = Booking::with(['room', 'user'])
            ->when($status, fn ($q) => $q->where('status', $status))
            ->orderByDesc('start_at')
            ->paginate(12)
            ->withQueryString();

        return view('admin.bookings.index', compact('bookings', 'status'));
    }

    public function approve(Request $request, Booking $booking)
    {
        $this->service->approve($booking, $request->input('admin_note'));

        return back()->with('success', "Approved {$booking->room->name} for {$booking->user->name}.");
    }

    public function reject(Request $request, Booking $booking)
    {
        $this->service->reject($booking, $request->input('admin_note'));

        return back()->with('success', "Rejected the booking from {$booking->user->name}.");
    }

    public function cancel(Request $request, Booking $booking)
    {
        $this->service->adminCancel($booking, $request->input('admin_note'));

        return back()->with('success', "Cancelled {$booking->user->name}'s booking for {$booking->room->name}.");
    }
}
