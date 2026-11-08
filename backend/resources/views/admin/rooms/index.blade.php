@extends('layouts.admin')
@section('title', 'Rooms')
@section('subtitle', 'Spaces students can book from the app.')
@section('actions')
    <a href="{{ route('admin.rooms.create') }}" class="rounded-xl bg-brand-700 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-brand-800">Add room</a>
@endsection

@section('content')
<div class="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
    @forelse ($rooms as $room)
        <article class="group overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200">
            <div class="relative aspect-[16/9] bg-gradient-to-br from-brand-100 to-slate-200">
                @if ($room->image_url)
                    <img src="{{ $room->image_url }}" alt="" class="h-full w-full object-cover" onerror="this.remove()">
                @endif
                <span class="absolute left-3 top-3 rounded-full bg-white/90 px-2.5 py-1 text-xs font-semibold text-slate-800 backdrop-blur">{{ $room->type }}</span>
                @unless ($room->is_active)
                    <span class="absolute right-3 top-3 rounded-full bg-slate-900/80 px-2.5 py-1 text-xs font-semibold text-white">Hidden</span>
                @endunless
            </div>
            <div class="p-5">
                <h2 class="font-bold text-slate-900">{{ $room->name }}</h2>
                <p class="mt-1 text-sm text-slate-500">{{ $room->location ?? 'No location set' }}</p>
                <div class="mt-4 flex items-center justify-between text-sm">
                    <span class="tabular-nums text-slate-600"><strong class="text-slate-900">{{ $room->capacity }}</strong> seats · <strong class="text-slate-900">{{ $room->upcoming_count }}</strong> upcoming</span>
                    <div class="flex gap-3">
                        <a href="{{ route('admin.rooms.edit', $room) }}" class="font-semibold text-brand-700 hover:underline">Edit</a>
                        <form method="POST" action="{{ route('admin.rooms.destroy', $room) }}" onsubmit="return confirm('Delete {{ $room->name }} and all its bookings? This cannot be undone.')">
                            @csrf @method('DELETE')
                            <button class="font-semibold text-rose-600 hover:underline">Delete</button>
                        </form>
                    </div>
                </div>
            </div>
        </article>
    @empty
        <p class="text-slate-500">No rooms yet. Add the first one.</p>
    @endforelse
</div>
@endsection
