<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBookingRequest;
use App\Http\Resources\BookingResource;
use App\Models\Booking;
use App\Services\BookingService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BookingController extends Controller
{
    public function __construct(private BookingService $service) {}

    /** Students see their own bookings. Admins see everyone's and can filter by status. */
    public function index(Request $request)
    {
        Booking::expireStale();
        $user = $request->user();

        $bookings = Booking::with(['room', 'user'])
            ->when(! $user->isAdmin(), fn ($q) => $q->where('user_id', $user->id))
            ->when($request->query('status'), fn ($q, $s) => $q->where('status', $s))
            ->orderByDesc('start_at')
            ->get();

        return BookingResource::collection($bookings);
    }

    public function store(StoreBookingRequest $request)
    {
        $booking = $this->service->create($request->user(), $request->validated());

        return (new BookingResource($booking->load(['room', 'user'])))
            ->response()->setStatusCode(201);
    }

    public function show(Request $request, Booking $booking)
    {
        $user = $request->user();
        abort_unless($user->isAdmin() || $booking->user_id === $user->id, 403, 'Not your booking.');

        return new BookingResource($booking->load(['room', 'user']));
    }

    public function cancel(Request $request, Booking $booking)
    {
        abort_unless($booking->user_id === $request->user()->id, 403, 'You can only cancel your own bookings.');

        return new BookingResource($this->service->cancel($booking)->load(['room', 'user']));
    }

    /** Admin only: approve, reject or cancel a booking. */
    public function updateStatus(Request $request, Booking $booking)
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['approved', 'rejected', 'cancelled'])],
            'admin_note' => ['nullable', 'string', 'max:255'],
        ]);
        $note = $data['admin_note'] ?? null;

        $booking = match ($data['status']) {
            'approved' => $this->service->approve($booking, $note),
            'rejected' => $this->service->reject($booking, $note),
            'cancelled' => $this->service->adminCancel($booking, $note),
        };

        return new BookingResource($booking->load(['room', 'user']));
    }
}
