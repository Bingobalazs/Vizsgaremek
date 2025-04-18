<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Post;
use http\Env\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
// Eloquent
use App\Models\Auto;

class FriendsController extends Controller
{

    public function friends()
    {
        $user = auth()->user();
        $id = $user->id;

        //Kilistázza az adott felhasználó barátait
        $friends = DB::table('friends')
            ->join('users as u1', 'friends.user_id', '=', 'u1.id')
            ->join('users as u2', 'friends.other_user_id', '=', 'u2.id')
            ->where('friends.user_id', $id)
            ->orWhere('friends.other_user_id', $id)
            ->select(
                'friends.id',
                'friends.created_at',
                'friends.updated_at',
                DB::raw("CASE
                    WHEN friends.user_id = $id THEN u2.id
                    ELSE u1.id
                END as user_id"),
                DB::raw("CASE
                    WHEN friends.user_id = $id THEN u2.name
                    ELSE u1.name
                END as name")
            )
            ->get();

        return response()->json($friends, 200, ['Content-Type' => 'application/json']);
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

        return response()->json(["message" => "Fasza"]);
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

        return response()->json($users);

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

        return response()->json($userId);

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

    public function search($query)
    {
        $result = User::where('name', 'like', "%$query")
            ->orWhere('email', 'like', "%$query")
            ->get();
        return response()-> json($result, 200, ['Content-Type' => 'application/json']);

    }

    public function getUserWithPosts($userId)
    {
        $user = User::findOrFail($userId);

        $posts = $user->posts()->orderBy('created_at', 'desc')->paginate(10);

        return response()->json([
            'user'  => $user,
            'posts' => $posts,
        ]);
    }
}
