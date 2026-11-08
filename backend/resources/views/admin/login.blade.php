<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign in · Roomly Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { font-family: "Plus Jakarta Sans", system-ui, sans-serif; }
        input[type=email], input[type=password], input[type=text] { color: #0f172a; background: #fff; }
        /* Chrome autofill: keep our white field and dark text instead of Chrome's blue tint */
        input:-webkit-autofill, input:-webkit-autofill:hover, input:-webkit-autofill:focus {
            -webkit-text-fill-color: #0f172a;
            -webkit-box-shadow: 0 0 0 1000px #fff inset;
            caret-color: #0f172a;
            transition: background-color 9999s ease-out 0s;
        }
    </style>
</head>
<body class="grid min-h-screen bg-slate-900 lg:grid-cols-2">
    <section class="relative hidden overflow-hidden lg:block">
        <img src="https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1400&q=70" alt="" class="absolute inset-0 h-full w-full object-cover opacity-50">
        <div class="absolute inset-0 bg-gradient-to-t from-slate-900 via-slate-900/40 to-transparent"></div>
        <div class="absolute bottom-0 p-12 text-white">
            <p class="text-4xl font-extrabold leading-tight">Every room,<br>one calendar.</p>
            <p class="mt-3 max-w-sm text-slate-300">Students book on mobile. You approve here. No double bookings, ever.</p>
        </div>
    </section>
    <section class="flex items-center justify-center bg-white px-6 py-12">
        <form method="POST" action="{{ url('/admin/login') }}" class="w-full max-w-sm">
            @csrf
            <div class="mb-8 flex items-center gap-3">
                <div class="grid h-11 w-11 place-items-center rounded-xl bg-gradient-to-br from-teal-500 to-teal-700 text-lg font-extrabold text-white">R</div>
                <span class="text-xl font-extrabold text-slate-900">Roomly</span>
            </div>
            <h1 class="text-2xl font-extrabold text-slate-900">Admin sign in</h1>
            <p class="mt-1 text-sm text-slate-500">Manage rooms and review booking requests.</p>

            @error('email')
                <div role="alert" class="mt-6 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800">{{ $message }}</div>
            @enderror

            <label for="email" class="mt-6 block text-sm font-semibold text-slate-700">Email</label>
            <input id="email" name="email" type="email" value="{{ old('email') }}" autocomplete="username" required
                   class="mt-1.5 w-full rounded-xl border border-slate-300 px-4 py-3 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-600/20">

            <label for="password" class="mt-4 block text-sm font-semibold text-slate-700">Password</label>
            <div class="relative mt-1.5">
                <input id="password" name="password" type="password" autocomplete="current-password" required
                       class="w-full rounded-xl border border-slate-300 px-4 py-3 pr-20 outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-600/20">
                <button type="button" id="toggle-password" aria-controls="password" aria-pressed="false"
                        class="absolute inset-y-0 right-2 my-auto h-9 rounded-lg px-3 text-sm font-semibold text-teal-700 hover:bg-teal-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-teal-600">Show</button>
            </div>

            <label class="mt-4 flex items-center gap-2 text-sm text-slate-600">
                <input type="checkbox" name="remember" class="rounded border-slate-300 text-teal-700"> Remember me
            </label>

            <button class="mt-6 w-full rounded-xl bg-teal-700 py-3 font-semibold text-white hover:bg-teal-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-teal-600 focus-visible:ring-offset-2">Sign in</button>
            <p class="mt-6 text-center text-xs text-slate-400">Demo: admin@roomly.test / password</p>
        </form>
    </section>
    <script>
        const pw = document.getElementById('password');
        const toggle = document.getElementById('toggle-password');
        toggle.addEventListener('click', () => {
            const show = pw.type === 'password';
            pw.type = show ? 'text' : 'password';
            toggle.textContent = show ? 'Hide' : 'Show';
            toggle.setAttribute('aria-pressed', show);
            pw.focus();
        });
    </script>
</body>
</html>
