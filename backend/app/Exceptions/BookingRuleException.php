<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\Request;

class BookingRuleException extends Exception
{
    public function __construct(string $message, public int $status = 409)
    {
        parent::__construct($message);
    }

    public function render(Request $request)
    {
        if ($request->is('api/*') || $request->expectsJson()) {
            return response()->json(['message' => $this->getMessage()], $this->status);
        }

        return back()->with('error', $this->getMessage());
    }
}
