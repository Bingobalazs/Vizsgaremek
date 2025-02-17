<?php

namespace App\Http\Controllers;

use App\Models\Identicard;
use Illuminate\Http\Request;
use App\Models\User;

class IdentiController extends Controller
{


    public function share($username)
    {
        $user = Identicard::where('username', $username)->firstOrFail();
        return view('blabber.identicard',  compact('user'));
    }
}
