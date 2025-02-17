<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class IdentiController extends Controller
{
    public function show($username)
    {
        $user = User::where('username', $username)->firstOrFail();
        return view('profiles.show', compact('user'));
    }

    public function share($username)
    {
        $user = User::where('username', $username)->firstOrFail();
        return view('profiles.identitybeam', compact('user'));
    }
}
