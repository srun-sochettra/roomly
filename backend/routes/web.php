<?php

use App\Http\Controllers\Admin;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/admin');

Route::prefix('admin')->name('admin.')->group(function () {
    Route::middleware('guest')->group(function () {
        Route::get('/login', [Admin\AuthController::class, 'showLogin'])->name('login');
        Route::post('/login', [Admin\AuthController::class, 'login']);
    });

    Route::middleware(['auth', 'admin'])->group(function () {
        Route::post('/logout', [Admin\AuthController::class, 'logout'])->name('logout');
        Route::get('/', Admin\DashboardController::class)->name('dashboard');

        Route::get('/bookings', [Admin\BookingController::class, 'index'])->name('bookings.index');
        Route::patch('/bookings/{booking}/approve', [Admin\BookingController::class, 'approve'])->name('bookings.approve');
        Route::patch('/bookings/{booking}/reject', [Admin\BookingController::class, 'reject'])->name('bookings.reject');
        Route::patch('/bookings/{booking}/cancel', [Admin\BookingController::class, 'cancel'])->name('bookings.cancel');

        Route::resource('rooms', Admin\RoomController::class)->except('show');
    });
});
