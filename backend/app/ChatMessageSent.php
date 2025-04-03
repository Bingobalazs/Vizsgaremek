<?php

namespace App;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatMessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $chat;

    public function __construct($chat)
    {
        $this->chat = $chat;
    }

    public function broadcastOn()
    {
        // Publikus csatorna; ha szeretnéd, itt áttérhetsz privát csatornára és implementálhatod a csatornák jogosultság-ellenőrzését.
        return new Channel('chat-channel');
    }

    public function broadcastAs()
    {
        return 'chat.message';
    }
}
