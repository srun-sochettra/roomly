@extends('layouts.admin')
@section('title', 'Bookings')
@section('subtitle', 'Review requests from the mobile app.')

@section('content')
<nav class="mb-5 flex flex-wrap gap-2" aria-label="Filter by status">
    @foreach ([null => 'All', 'pending' => 'Pending', 'approved' => 'Approved', 'rejected' => 'Rejected', 'cancelled' => 'Cancelled', 'expired' => 'Expired'] as $key => $label)
        <a href="{{ route('admin.bookings.index', $key ? ['status' => $key] : []) }}"
           @if ($status == $key) aria-current="page" @endif
           class="rounded-full px-4 py-1.5 text-sm font-semibold transition {{ $status == $key ? 'bg-slate-900 text-white' : 'bg-white text-slate-600 ring-1 ring-slate-200 hover:bg-slate-100' }}">{{ $label }}</a>
    @endforeach
</nav>

<div class="overflow-x-auto rounded-2xl bg-white shadow-sm ring-1 ring-slate-200">
    <table class="w-full min-w-[760px] text-left text-sm">
        <thead class="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
                <th scope="col" class="px-6 py-3 font-semibold">Room</th>
                <th scope="col" class="px-6 py-3 font-semibold">Student</th>
                <th scope="col" class="px-6 py-3 font-semibold">When</th>
                <th scope="col" class="px-6 py-3 font-semibold">Status</th>
                <th scope="col" class="px-6 py-3 font-semibold"><span class="sr-only">Actions</span></th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
            @forelse ($bookings as $b)
                <tr class="hover:bg-slate-50/60">
                    <td class="px-6 py-4">
                        <p class="font-semibold text-slate-900">{{ $b->room->name }}</p>
                        <p class="text-slate-500">{{ $b->attendees }} people{{ $b->purpose ? ' · '.$b->purpose : '' }}</p>
                    </td>
                    <td class="px-6 py-4">
                        <p class="font-medium text-slate-800">{{ $b->user->name }}</p>
                        <p class="text-slate-500">{{ $b->user->email }}</p>
                    </td>
                    <td class="whitespace-nowrap px-6 py-4 tabular-nums text-slate-700">
                        {{ $b->start_at->format('D j M') }}<br>
                        <span class="text-slate-500">{{ $b->start_at->format('H:i') }} – {{ $b->end_at->format('H:i') }}</span>
                    </td>
                    <td class="px-6 py-4">
                        <x-status-badge :status="$b->status" />
                        @if ($b->admin_note)<p class="mt-1 max-w-[180px] text-xs text-slate-500">{{ $b->admin_note }}</p>@endif
                    </td>
                    <td class="px-6 py-4">
                        @if ($b->status === 'pending')
                            <x-review-buttons :booking="$b" />
                        @elseif ($b->status === 'approved' && $b->start_at->isFuture())
                            <form method="POST" action="{{ route('admin.bookings.cancel', $b) }}"
                                  onsubmit="const n = prompt('Cancel this approved booking? The student will see your reason in the app.\n\nReason (optional):'); if (n === null) return false; this.admin_note.value = n;">
                                @csrf @method('PATCH')
                                <input type="hidden" name="admin_note">
                                <button class="rounded-lg border border-rose-200 px-3 py-1.5 text-xs font-semibold text-rose-700 hover:bg-rose-50">Cancel booking</button>
                            </form>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="5" class="px-6 py-16 text-center text-slate-500">No bookings match this filter.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
<div class="mt-6">{{ $bookings->links() }}</div>
@endsection
