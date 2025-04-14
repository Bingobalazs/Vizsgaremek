<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Chat;

class ChatController extends Controller
{
    public function postChat(Request $request, $friend_id)
    {
        $user = auth()->user();
        $user_id = $user->id;
        $chatContent = $request->input('chat');

        $data = Chat::create([
            'from_id' => $user_id,
            'to_id'   => $friend_id,
            'chat'    => $chatContent,
        ]);

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
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        // A legkorábbi üzenetek legyenek elöl, ezért fordított sorrendben
        $messagesArray = $messages->toArray();
        $messagesArray['data'] = array_values(array_reverse($messagesArray['data']));

        return response()->json($messagesArray);
    }

    // SSE végpont a valós idejű kommunikációhoz
    public function streamChat(Request $request, $friend_id)
    {
        $user = auth()->user();
        $user_id = $user->id;
        // Opcionálisan adhatjuk át a kliens által ismert legutolsó üzenet azonosítót
        $lastMessageId = $request->query('lastMessageId', 0);

        return response()->stream(function () use ($user_id, $friend_id, &$lastMessageId) {
            while (true) {
                $newMessages = DB::table('chat')
                    ->where(function ($query) use ($user_id, $friend_id) {
                        $query->where('from_id', $user_id)
                              ->where('to_id', $friend_id);
                    })
                    ->orWhere(function ($query) use ($user_id, $friend_id) {
                        $query->where('from_id', $friend_id)
                              ->where('to_id', $user_id);
                    })
                    ->where('id', '>', $lastMessageId)
                    ->orderBy('created_at', 'asc')
                    ->get();

                if ($newMessages->count() > 0) {
                    foreach ($newMessages as $msg) {
                        echo "data: " . json_encode($msg) . "\n\n";
                        flush();
                        $lastMessageId = $msg->id;
                    }
                }
                // Minden ciklus végén ürítsük a puffert és várjunk egy másodpercet
                ob_flush();
                flush();
                sleep(1);
            }
        }, 200, [
            'Content-Type'  => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection'    => 'keep-alive',
            'Access-Control-Allow-Origin' => '*'
        ]);
    }
}
