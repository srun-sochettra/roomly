@extends('layouts.admin')
@section('title', 'Dashboard')
@section('subtitle', now()->format('l, j F Y'))

@section('content')
<div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
    @foreach ([
        ['Pending review', $stats['pending'], 'bg-amber-50 text-amber-600', 'M12 8v4l3 2m6-2a9 9 0 11-18 0 9 9 0 0118 0z', route('admin.bookings.index', ['status' => 'pending'])],
        ['Approved today', $stats['today'], 'bg-emerald-50 text-emerald-600', 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z', route('admin.bookings.index', ['status' => 'approved'])],
        ['Active rooms', $stats['rooms'], 'bg-sky-50 text-sky-600', 'M4 21V5a2 2 0 012-2h12a2 2 0 012 2v16M2 21h20M9 7h1m4 0h1M9 11h1m4 0h1M10 21v-4h4v4', route('admin.rooms.index')],
        ['Students', $stats['students'], 'bg-slate-100 text-slate-600', 'M17 20h5v-2a4 4 0 00-5-3.87M9 20H2v-2a4 4 0 015-3.87m6-4.13a4 4 0 11-8 0 4 4 0 018 0zm6 2a3 3 0 11-6 0 3 3 0 016 0z', null],
    ] as [$label, $value, $tone, $icon, $link])
        <{{ $link ? 'a href='.$link : 'div' }} class="group flex items-center gap-4 rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 transition {{ $link ? 'hover:ring-brand-500 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500' : '' }}">
            <div class="grid h-12 w-12 shrink-0 place-items-center rounded-xl {{ $tone }}">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="{{ $icon }}"/></svg>
            </div>
            <div>
                <p class="text-sm font-medium text-slate-500">{{ $label }}</p>
                <p class="text-2xl font-extrabold tabular-nums text-slate-900">{{ $value }}</p>
            </div>
        </{{ $link ? 'a' : 'div' }}>
    @endforeach
</div>

<div class="mt-8 grid gap-6 lg:grid-cols-5">
    <section class="rounded-2xl bg-white shadow-sm ring-1 ring-slate-200 lg:col-span-3">
        <div class="flex items-center justify-between border-b border-slate-100 px-6 py-4">
            <h2 class="font-bold text-slate-900">Waiting for you</h2>
            <a href="{{ route('admin.bookings.index', ['status' => 'pending']) }}" class="text-sm font-semibold text-brand-700 hover:underline">View all</a>
        </div>
        @forelse ($pending as $b)
            <div class="flex flex-wrap items-center gap-4 border-b border-slate-100 px-6 py-4 last:border-0">
                <img src="{{ $b->room->image_url }}" alt="" class="h-12 w-12 rounded-xl bg-slate-100 object-cover">
                <div class="min-w-0 flex-1">
                    <p class="truncate font-semibold text-slate-900">{{ $b->room->name }} <span class="font-normal text-slate-400">·</span> <span class="font-medium text-slate-600">{{ $b->user->name }}</span></p>
                    <p class="text-sm tabular-nums text-slate-500">{{ $b->start_at->format('D j M, H:i') }} – {{ $b->end_at->format('H:i') }} · {{ $b->attendees }} people</p>
                    @if ($b->purpose)<p class="truncate text-sm text-slate-400">{{ $b->purpose }}</p>@endif
                </div>
                <x-review-buttons :booking="$b" />
            </div>
        @empty
            <div class="px-6 py-14 text-center">
                <div class="mx-auto mb-3 grid h-12 w-12 place-items-center rounded-full bg-emerald-50 text-emerald-600">
                    <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                </div>
                <p class="font-semibold text-slate-700">All caught up</p>
                <p class="mt-1 text-sm text-slate-500">New booking requests from the app will show up here.</p>
            </div>
        @endforelse
    </section>

    <section class="rounded-2xl bg-white shadow-sm ring-1 ring-slate-200 lg:col-span-2">
        <div class="border-b border-slate-100 px-6 py-4"><h2 class="font-bold text-slate-900">Today’s schedule</h2></div>
        <ol class="space-y-4 px-6 py-5">
            @forelse ($todaySchedule as $b)
                @php $live = $b->start_at->isPast() && $b->end_at->isFuture(); @endphp
                <li class="flex gap-4">
                    <div class="w-14 shrink-0 text-right text-sm font-bold tabular-nums text-brand-700">{{ $b->start_at->format('H:i') }}</div>
                    <div class="border-l-2 {{ $live ? 'border-brand-500' : 'border-brand-100' }} pl-4">
                        <p class="font-semibold text-slate-900">{{ $b->room->name }}
                            @if ($live)<span class="ml-1 rounded-full bg-brand-50 px-2 py-0.5 text-xs font-bold text-brand-700">In use</span>@endif
                        </p>
                        <p class="text-sm text-slate-500">{{ $b->user->name }} · until {{ $b->end_at->format('H:i') }}</p>
                    </div>
                </li>
            @empty
                <li class="py-8 text-center text-sm text-slate-500">No approved bookings today.</li>
            @endforelse
        </ol>
    </section>
</div>
@endsection
