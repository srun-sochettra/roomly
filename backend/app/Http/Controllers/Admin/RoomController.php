<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\RoomRequest;
use App\Models\Room;

class RoomController extends Controller
{
    public function index()
    {
        $rooms = Room::withCount(['bookings as upcoming_count' => fn ($q) => $q
            ->where('status', 'approved')->where('start_at', '>', now())])
            ->orderBy('name')->get();

        return view('admin.rooms.index', compact('rooms'));
    }

    public function create()
    {
        return view('admin.rooms.form', ['room' => new Room(['is_active' => true, 'capacity' => 10])]);
    }

    public function store(RoomRequest $request)
    {
        Room::create([...$request->validated(), 'is_active' => $request->boolean('is_active')]);

        return redirect()->route('admin.rooms.index')->with('success', 'Room created.');
    }

    public function edit(Room $room)
    {
        return view('admin.rooms.form', compact('room'));
    }

    public function update(RoomRequest $request, Room $room)
    {
        $room->update([...$request->validated(), 'is_active' => $request->boolean('is_active')]);

        return redirect()->route('admin.rooms.index')->with('success', 'Room updated.');
    }

    public function destroy(Room $room)
    {
        $room->delete();

        return redirect()->route('admin.rooms.index')->with('success', "Deleted {$room->name}.");
    }
}
