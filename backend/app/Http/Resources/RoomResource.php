<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoomResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'capacity' => $this->capacity,
            'location' => $this->location,
            'image_url' => $this->image_url,
            'description' => $this->description,
            'is_active' => $this->is_active,
            // Only on the rooms list: "busy until 16:00" or "free until 14:00" (until = null means free all day).
            'availability' => $this->when($this->relationLoaded('currentBooking'), fn () => $this->currentBooking
                ? ['state' => 'busy', 'until' => $this->currentBooking->end_at->toIso8601String()]
                : ['state' => 'free', 'until' => $this->nextBookingToday?->start_at->toIso8601String()]),
        ];
    }
}
