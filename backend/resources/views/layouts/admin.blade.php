<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Dashboard') · Roomly Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { theme: { extend: {
            fontFamily: { sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'] },
            colors: { brand: { 50:'#f0fdfa',100:'#ccfbf1',500:'#14b8a6',600:'#0d9488',700:'#0f766e',800:'#115e59',900:'#134e4a' } }
        } } }
    </script>
</head>
<body class="bg-slate-50 font-sans text-slate-800 antialiased">
@php
    $pendingCount = \App\Models\Booking::where('status', 'pending')->count();
    $nav = [
        ['admin.dashboard', 'Dashboard', 'M3 12l9-9 9 9M5 10v10h5v-6h4v6h5V10'],
        ['admin.bookings.index', 'Bookings', 'M8 7V3m8 4V3M4 11h16M5 5h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V6a1 1 0 011-1z'],
        ['admin.rooms.index', 'Rooms', 'M4 21V5a2 2 0 012-2h12a2 2 0 012 2v16M2 21h20M9 7h1m4 0h1M9 11h1m4 0h1M10 21v-4h4v4'],
    ];
@endphp
<div class="flex min-h-screen">
    {{-- Sticky sidebar: stays in view while the page scrolls, so Log out is always reachable. --}}
    <aside class="sticky top-0 hidden h-screen w-64 shrink-0 flex-col bg-slate-900 text-slate-300 md:flex">
        <div class="flex items-center gap-3 px-6 py-6">
            <div class="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-brand-500 to-brand-700 font-extrabold text-white">R</div>
            <div>
                <p class="text-lg font-bold text-white">Roomly</p>
                <p class="text-xs text-slate-400">Admin console</p>
            </div>
        </div>
        <nav class="mt-2 flex-1 space-y-1 overflow-y-auto px-3">
            @foreach ($nav as [$route, $label, $icon])
                @php $active = request()->routeIs(str_replace('.index', '.*', $route)); @endphp
                <a href="{{ route($route) }}" @if ($active) aria-current="page" @endif
                   class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 {{ $active ? 'bg-white/10 text-white' : 'hover:bg-white/5 hover:text-white' }}">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="{{ $icon }}"/></svg>
                    {{ $label }}
                    @if ($label === 'Bookings' && $pendingCount)
                        <span class="ml-auto rounded-full bg-amber-400 px-2 py-0.5 text-xs font-bold text-slate-900">{{ $pendingCount }}<span class="sr-only"> pending</span></span>
                    @endif
                </a>
            @endforeach
        </nav>
        <div class="flex items-center gap-3 border-t border-white/10 p-4">
            <div class="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-white/10 text-sm font-bold text-white">
                {{ collect(explode(' ', auth()->user()->name))->take(2)->map(fn ($w) => mb_substr($w, 0, 1))->join('') }}
            </div>
            <div class="min-w-0 flex-1">
                <p class="truncate text-sm font-semibold text-white">{{ auth()->user()->name }}</p>
                <p class="truncate text-xs text-slate-400">{{ auth()->user()->email }}</p>
            </div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button title="Log out" class="rounded-lg p-2 text-slate-400 hover:bg-white/10 hover:text-white focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500">
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M15 17l5-5-5-5M20 12H9M12 21H5a2 2 0 01-2-2V5a2 2 0 012-2h7"/></svg>
                    <span class="sr-only">Log out</span>
                </button>
            </form>
        </div>
    </aside>

    <div class="flex min-w-0 flex-1 flex-col">
        <header class="flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3 md:hidden">
            <span class="font-bold">Roomly Admin</span>
            <nav class="flex gap-3 text-sm font-medium">
                @foreach ($nav as [$route, $label])
                    <a href="{{ route($route) }}" class="text-slate-600 hover:text-brand-700">{{ $label }}</a>
                @endforeach
            </nav>
        </header>

        <main class="mx-auto w-full max-w-6xl flex-1 px-4 py-8 md:px-10">
            <div class="mb-8 flex flex-wrap items-end justify-between gap-4">
                <div>
                    <h1 class="text-2xl font-extrabold tracking-tight text-slate-900">@yield('title')</h1>
                    <p class="mt-1 text-sm text-slate-500">@yield('subtitle')</p>
                </div>
                @yield('actions')
            </div>

            @if (session('success'))
                <div role="status" class="mb-6 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-800">{{ session('success') }}</div>
            @endif
            @if (session('error'))
                <div role="alert" class="mb-6 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-medium text-rose-800">{{ session('error') }}</div>
            @endif

            @yield('content')
        </main>
    </div>
</div>
</body>
</html>
