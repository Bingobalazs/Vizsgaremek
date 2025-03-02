<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
// Eloquent
use App\Models\Auto;

class FriendsController extends Controller
{

    public function friends($id)
    {
        $friends = DB::table('friends')
            ->where('user_id', $id)
            ->orWhere('othr_user_id', $id)
            ->get();

        return response()->json($friends);
    }

    public function index()
    {
        return "friendscontroller works";
    }

    //friends
    public function jeloles($id)
    {
        $userId = Auth::id();

        $users = DB::table('users')
            ->where('id', '!=', $userId)
            ->get();

        $exists = DB::table('jelolesek')
            ->where('from_id', $userId)
            ->where('to_id', $id)
            ->exists();

        if(!$exists)
        {
            DB::table('jelolesek')->insert([
                'from_id' => $userId,
                'to_id' => $id,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return redirect()->back()->with(compact('users'));
    }

    public function friend_req()
    {

        $id = Auth::id();

        $users = DB::table('users')
            ->join('jelolesek', function ($join) use ($id) {
                $join->on('users.id', '=', 'jelolesek.from_id');
            })
            ->where('jelolesek.to_id', '=', $id)
            ->distinct()
            ->select('users.*')
            ->get();

        return view('keresek', compact('users'));

    }

    public function accept($id)
    {

        $userId = Auth::id();

        $connection = DB::table('jelolesek')
            ->where(function ($query) use ($userId, $id) {
                $query->where('from_id', '=', $userId)
                    ->where('to_id', '=', $id);
            })
            ->orWhere(function ($query) use ($userId, $id) {
                $query->where('from_id', '=', $id)
                    ->where('to_id', '=', $userId);
            })
            ->first(); // Lekérjük az első találatot

        // Ha létezik a kapcsolat, töröljük
        if ($connection) {
            DB::table('jelolesek')
                ->where('from_id', '=', $userId)
                ->where('to_id', '=', $id)
                ->orWhere(function ($query) use ($userId, $id) {
                    $query->where('from_id', '=', $id)
                        ->where('to_id', '=', $userId);
                })
                ->delete();
        }

        $exists = DB::table('friends')
            ->where('user_id', $userId)
            ->where('other_user_id', $id)
            ->exists();

        if(!$exists)
        {
            DB::table('friends')->insert([
                'user_id' => $userId,
                'other_user_id' => $id,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return redirect()->back();

    }


    public function users()
    {
        $id = Auth::id();

        $users = DB::table('users')
            ->where('id', '!=', $id)
            ->get();

        return json_encode($users);
    }

    public function viewUsers()
    {
        $id = Auth::id();

        $users = DB::table('users')
            ->where('id', '!=', $id)
            ->get();

        return view('users', compact('users'));
    }

}
