<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RoomRequest;
use App\Http\Resources\RoomResource;
use App\Models\Booking;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class RoomController extends Controller
{
    public function index(Request $request)
    {
        $rooms = Room::query()
            ->with(['currentBooking', 'nextBookingToday'])
            ->when(! $request->user()->isAdmin(), fn ($q) => $q->where('is_active', true))
            ->when($request->query('type'), fn ($q, $type) => $q->where('type', $type))
            ->when($request->query('search'), fn ($q, $s) => $q->where(fn ($q) => $q
                ->where('name', 'like', "%{$s}%")
                ->orWhere('location', 'like', "%{$s}%")))
            ->orderBy('name')
            ->get();

        return RoomResource::collection($rooms);
    }

    /** Room details plus the upcoming slots that are already taken. */
    public function show(Room $room)
    {
        $schedule = $room->bookings()
            ->whereIn('status', Booking::ACTIVE)
            ->where('end_at', '>', now())
            ->orderBy('start_at')
            ->limit(20)
            ->get(['start_at', 'end_at', 'status'])
            ->map(fn ($b) => [
                'start_at' => $b->start_at->toIso8601String(),
                'end_at' => $b->end_at->toIso8601String(),
                'status' => $b->status,
            ]);

        return (new RoomResource($room))->additional(['schedule' => $schedule]);
    }

    /** Taken slots for one day, for the timeline in the app. GET /rooms/{room}/schedule?date=2026-11-20 */
    public function schedule(Request $request, Room $room)
    {
        $data = $request->validate(['date' => ['required', 'date_format:Y-m-d']]);
        $dayStart = Carbon::parse($data['date'])->startOfDay();
        $dayEnd = $dayStart->copy()->addDay();

        $slots = $room->bookings()
            ->whereIn('status', Booking::ACTIVE)
            ->where('start_at', '<', $dayEnd)
            ->where('end_at', '>', $dayStart)
            ->orderBy('start_at')
            ->get()
            ->map(fn ($b) => [
                'start_at' => $b->start_at->toIso8601String(),
                'end_at' => $b->end_at->toIso8601String(),
                'status' => $b->status,
                'mine' => $b->user_id === $request->user()->id,
            ]);

        return response()->json(['date' => $data['date'], 'data' => $slots]);
    }

    public function store(RoomRequest $request)
    {
        return (new RoomResource(Room::create($request->validated())))
            ->response()->setStatusCode(201);
    }

    public function update(RoomRequest $request, Room $room)
    {
        $room->update($request->validated());

        return new RoomResource($room);
    }

    public function destroy(Room $room)
    {
        $room->delete();

        return response()->noContent();
    }
}
