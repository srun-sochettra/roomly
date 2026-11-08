@props(['status'])
@php
    $styles = [
        'pending' => 'bg-amber-50 text-amber-800 ring-amber-200',
        'approved' => 'bg-emerald-50 text-emerald-800 ring-emerald-200',
        'rejected' => 'bg-rose-50 text-rose-800 ring-rose-200',
        'cancelled' => 'bg-slate-100 text-slate-600 ring-slate-200',
        'expired' => 'bg-slate-100 text-slate-500 ring-slate-200',
    ];
@endphp
<span class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset {{ $styles[$status] ?? $styles['cancelled'] }}">
    <span class="h-1.5 w-1.5 rounded-full bg-current" aria-hidden="true"></span>{{ ucfirst($status) }}
</span>
