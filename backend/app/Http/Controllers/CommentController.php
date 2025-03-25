<?php

namespace App\Http\Controllers;

use App\Models\Post;

class CommentController extends Controller
{
    public function countComments(Post $post)
    {
        $count = $post->comments()->count();
        return response()->json(['count' => $count]);
    }
}
