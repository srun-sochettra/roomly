<?php

namespace App\Http\Requests;

use App\Models\Room;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Validator;

class StoreBookingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'room_id' => ['required', 'integer', 'exists:rooms,id'],
            'start_at' => ['required', 'date', 'after:now'],
            'end_at' => ['required', 'date', 'after:start_at'],
            'attendees' => ['required', 'integer', 'min:1'],
            'purpose' => ['nullable', 'string', 'max:255'],
        ];
    }

    /** Rules that need more than one field or a database lookup. */
    public function after(): array
    {
        return [
            function (Validator $validator) {
                if ($validator->errors()->isNotEmpty()) {
                    return;
                }

                $room = Room::find($this->room_id);
                if (! $room->is_active) {
                    $validator->errors()->add('room_id', 'This room is not available for booking.');
                }
                if ($this->attendees > $room->capacity) {
                    $validator->errors()->add('attendees', "{$room->name} fits at most {$room->capacity} people.");
                }

                $hours = Carbon::parse($this->start_at)->diffInMinutes(Carbon::parse($this->end_at)) / 60;
                if ($hours > 4) {
                    $validator->errors()->add('end_at', 'A booking can last at most 4 hours.');
                }
            },
        ];
    }
}
