<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\Room;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BookingRulesTest extends TestCase
{
    use RefreshDatabase;

    private function room(int $capacity = 4): Room
    {
        return Room::create(['name' => 'Focus Pod', 'type' => 'Study room', 'capacity' => $capacity]);
    }

    /** A slot tomorrow starting at $hour. */
    private function slot(int $hour, int $hours = 1): array
    {
        $start = now()->addDay()->startOfDay()->setHour($hour);

        return [
            'start_at' => $start->format('Y-m-d H:i:s'),
            'end_at' => $start->copy()->addHours($hours)->format('Y-m-d H:i:s'),
        ];
    }

    private function book(User $user, Room $room, array $slot, int $people = 2)
    {
        Sanctum::actingAs($user);

        return $this->postJson('/api/bookings', ['room_id' => $room->id, ...$slot, 'attendees' => $people]);
    }

    public function test_overlapping_booking_is_rejected_with_409(): void
    {
        $room = $this->room();
        $this->book(User::factory()->create(), $room, $this->slot(9, 2))->assertCreated();

        $this->book(User::factory()->create(), $room, $this->slot(10, 2))
            ->assertStatus(409)
            ->assertJsonPath('message', 'This room is already booked for that time. Try another slot.');
    }

    public function test_back_to_back_bookings_are_allowed(): void
    {
        $room = $this->room();
        $this->book(User::factory()->create(), $room, $this->slot(9))->assertCreated();
        $this->book(User::factory()->create(), $room, $this->slot(10))->assertCreated();
    }

    public function test_attendees_cannot_exceed_room_capacity(): void
    {
        $this->book(User::factory()->create(), $this->room(4), $this->slot(9), 5)
            ->assertStatus(422)
            ->assertJsonValidationErrors('attendees');
    }

    public function test_bookings_cannot_start_in_the_past(): void
    {
        $start = now()->subDay()->setTime(9, 0);
        $this->book(User::factory()->create(), $this->room(), [
            'start_at' => $start->format('Y-m-d H:i:s'),
            'end_at' => $start->copy()->addHour()->format('Y-m-d H:i:s'),
        ])->assertStatus(422)->assertJsonValidationErrors('start_at');
    }

    public function test_students_cannot_use_admin_routes(): void
    {
        $student = User::factory()->create();
        $id = $this->book($student, $this->room(), $this->slot(9))->json('data.id');

        $this->patchJson("/api/bookings/{$id}/status", ['status' => 'approved'])->assertForbidden();
    }

    public function test_students_cannot_cancel_someone_elses_booking(): void
    {
        $id = $this->book(User::factory()->create(), $this->room(), $this->slot(9))->json('data.id');

        Sanctum::actingAs(User::factory()->create());
        $this->patchJson("/api/bookings/{$id}/cancel")->assertForbidden();
    }

    public function test_admin_can_approve_then_cancel_a_booking(): void
    {
        $id = $this->book(User::factory()->create(), $this->room(), $this->slot(9))->json('data.id');

        Sanctum::actingAs(User::factory()->create(['role' => 'admin']));
        $this->patchJson("/api/bookings/{$id}/status", ['status' => 'approved'])
            ->assertOk()->assertJsonPath('data.status', 'approved');
        $this->patchJson("/api/bookings/{$id}/status", ['status' => 'cancelled', 'admin_note' => 'Room maintenance'])
            ->assertOk()->assertJsonPath('data.status', 'cancelled');
    }

    public function test_unreviewed_pending_bookings_expire(): void
    {
        $booking = Booking::create([
            'user_id' => User::factory()->create()->id,
            'room_id' => $this->room()->id,
            'start_at' => now()->subHour(),
            'end_at' => now()->addHour(),
            'attendees' => 2,
            'status' => 'pending',
        ]);

        $this->artisan('bookings:expire')->assertSuccessful();

        $this->assertSame('expired', $booking->fresh()->status);
    }
}
