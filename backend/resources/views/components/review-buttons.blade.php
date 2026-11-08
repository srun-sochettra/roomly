@props(['booking'])
<div class="flex gap-2">
    <form method="POST" action="{{ route('admin.bookings.approve', $booking) }}">
        @csrf @method('PATCH')
        <button class="rounded-lg bg-brand-700 px-3 py-1.5 text-xs font-semibold text-white hover:bg-brand-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 focus-visible:ring-offset-2">Approve</button>
    </form>
    <form method="POST" action="{{ route('admin.bookings.reject', $booking) }}"
          onsubmit="const n = prompt('Reason for rejecting (optional):'); if (n === null) return false; this.admin_note.value = n;">
        @csrf @method('PATCH')
        <input type="hidden" name="admin_note">
        <button class="rounded-lg border border-slate-300 px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-100">Reject</button>
    </form>
</div>
