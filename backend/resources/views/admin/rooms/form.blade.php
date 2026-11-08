@extends('layouts.admin')
@section('title', $room->exists ? 'Edit '.$room->name : 'New room')
@section('subtitle', 'Students see these details in the app.')

@section('content')
@php $input = 'mt-1.5 w-full rounded-xl border border-slate-300 bg-white px-4 py-2.5 outline-none focus:border-brand-600 focus:ring-2 focus:ring-brand-600/20'; @endphp
<form method="POST" action="{{ $room->exists ? route('admin.rooms.update', $room) : route('admin.rooms.store') }}"
      class="max-w-2xl space-y-5 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200 md:p-8">
    @csrf
    @if ($room->exists) @method('PUT') @endif

    <div>
        <label for="name" class="text-sm font-semibold text-slate-700">Name</label>
        <input id="name" name="name" value="{{ old('name', $room->name) }}" required class="{{ $input }}">
        @error('name')<p class="mt-1 text-sm text-rose-600">{{ $message }}</p>@enderror
    </div>
    <div class="grid gap-5 sm:grid-cols-2">
        <div>
            <label for="type" class="text-sm font-semibold text-slate-700">Type</label>
            <select id="type" name="type" class="{{ $input }}">
                @foreach (\App\Models\Room::TYPES as $type)
                    <option @selected(old('type', $room->type) === $type)>{{ $type }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label for="capacity" class="text-sm font-semibold text-slate-700">Capacity</label>
            <input id="capacity" name="capacity" type="number" inputmode="numeric" min="1" value="{{ old('capacity', $room->capacity) }}" required class="{{ $input }}">
            @error('capacity')<p class="mt-1 text-sm text-rose-600">{{ $message }}</p>@enderror
        </div>
    </div>
    <div>
        <label for="location" class="text-sm font-semibold text-slate-700">Location <span class="font-normal text-slate-400">(optional)</span></label>
        <input id="location" name="location" value="{{ old('location', $room->location) }}" class="{{ $input }}">
    </div>
    <div>
        <label for="image_url" class="text-sm font-semibold text-slate-700">Image URL <span class="font-normal text-slate-400">(optional)</span></label>
        <input id="image_url" name="image_url" type="url" value="{{ old('image_url', $room->image_url) }}" class="{{ $input }}">
        @error('image_url')<p class="mt-1 text-sm text-rose-600">{{ $message }}</p>@enderror
    </div>
    <div>
        <label for="description" class="text-sm font-semibold text-slate-700">Description <span class="font-normal text-slate-400">(optional)</span></label>
        <textarea id="description" name="description" rows="3" class="{{ $input }}">{{ old('description', $room->description) }}</textarea>
    </div>
    <label class="flex items-center gap-3 text-sm font-medium text-slate-700">
        <input type="hidden" name="is_active" value="0">
        <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $room->is_active)) class="h-4 w-4 rounded border-slate-300 text-brand-700">
        Visible in the app
    </label>
    <div class="flex gap-3 pt-2">
        <button class="rounded-xl bg-brand-700 px-5 py-2.5 font-semibold text-white hover:bg-brand-800">{{ $room->exists ? 'Save changes' : 'Create room' }}</button>
        <a href="{{ route('admin.rooms.index') }}" class="rounded-xl px-5 py-2.5 font-semibold text-slate-600 hover:bg-slate-100">Cancel</a>
    </div>
</form>
@endsection
