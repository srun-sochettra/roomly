<?php

namespace Database\Seeders;

use App\Models\Booking;
use App\Models\Room;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::create(['name' => 'Roomly Admin', 'email' => 'admin@roomly.test', 'password' => 'password', 'role' => 'admin']);

        $students = collect([
            ['Srun Sochettra', 'student@roomly.test'],
            ['Sok Dara', 'dara@roomly.test'],
            ['Chan Sreyneang', 'sreyneang@roomly.test'],
        ])->map(fn ($s) => User::create(['name' => $s[0], 'email' => $s[1], 'password' => 'password', 'role' => 'student']));

        $img = fn (string $id) => "https://images.unsplash.com/{$id}?auto=format&fit=crop&w=1200&q=70";

        $rooms = collect([
            ['Focus Pod A', 'Study room', 4, 'Building A, Floor 2', $img('photo-1497366811353-6870744d04b2'), 'Quiet pod with a whiteboard. Good for pair study.'],
            ['Collab Room 204', 'Study room', 8, 'Building A, Floor 2', $img('photo-1524758631624-e2822e304c36'), 'Big table, wall-mounted screen and HDMI.'],
            ['Boardroom', 'Meeting room', 14, 'Building B, Floor 5', $img('photo-1497366216548-37526070297c'), 'Formal meeting room with a video-conference setup.'],
            ['Huddle Space', 'Meeting room', 6, 'Building B, Floor 3', $img('photo-1556761175-4b46a572b786'), 'Casual sofa seating for quick syncs.'],
            ['Computer Lab 1', 'Lab', 30, 'Building C, Floor 1', $img('photo-1517694712202-14dd9538aa97'), '30 desktop PCs with a projector.'],
            ['Lecture Hall', 'Hall', 120, 'Main Building', $img('photo-1562774053-701939374585'), 'Tiered seating, PA system and stage.'],
        ])->map(fn ($r) => Room::create([
            'name' => $r[0], 'type' => $r[1], 'capacity' => $r[2],
            'location' => $r[3], 'image_url' => $r[4], 'description' => $r[5],
        ]));

        $slot = fn (int $days, int $hour, int $len = 2) => [
            'start_at' => today()->addDays($days)->setHour($hour),
            'end_at' => today()->addDays($days)->setHour($hour + $len),
        ];

        $samples = [
            [$students[0], $rooms[1], $slot(1, 9), 5, 'Database group project', 'approved'],
            [$students[0], $rooms[0], $slot(2, 14), 2, 'Exam revision', 'pending'],
            [$students[1], $rooms[2], $slot(1, 13), 10, 'Club committee meeting', 'pending'],
            [$students[2], $rooms[4], $slot(3, 8, 3), 25, 'Flutter workshop', 'approved'],
            [$students[1], $rooms[3], $slot(0, 16, 1), 4, 'Team sync', 'approved'],
            [$students[2], $rooms[5], $slot(4, 9, 4), 100, 'Orientation rehearsal', 'rejected'],
        ];

        foreach ($samples as [$user, $room, $time, $people, $purpose, $status]) {
            Booking::create([
                'user_id' => $user->id, 'room_id' => $room->id, ...$time,
                'attendees' => $people, 'purpose' => $purpose, 'status' => $status,
                'admin_note' => $status === 'rejected' ? 'Hall is reserved for an official event.' : null,
            ]);
        }
    }
}
