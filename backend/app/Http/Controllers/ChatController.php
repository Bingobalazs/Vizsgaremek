<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Chat;
use App\ChatMessageSent;

class ChatController extends Controller
{
    public function postChat($user_id, $friend_id, $chat)
    {
        // Üzenet tárolása az adatbázisban
        $data = Chat::create([
            'from_id' => $user_id,
            'to_id'   => $friend_id,
            'chat'    => $chat,
        ]);

        // Az esemény broadcastolása reálisan frissítendő felhasználók felé.
        broadcast(new ChatMessageSent($data))->toOthers();

        return response()->json([
            'message' => 'Chat stored successfully!',
            'chat'    => $data,
        ], 201);
    }

    public function getchat($friend_id)
    {
        $user = auth()->user();
        $user_id = $user->id;

        $messages = DB::table('chat')
            ->where(function ($query) use ($user_id, $friend_id) {
                $query->where('from_id', $user_id)
                      ->where('to_id', $friend_id);
            })
            ->orWhere(function ($query) use ($user_id, $friend_id) {
                $query->where('from_id', $friend_id)
                      ->where('to_id', $user_id);
            })
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json($messages);
    }
}
