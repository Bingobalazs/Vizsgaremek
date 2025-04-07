<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Post;
use App\Models\Comment;

class CommentController extends Controller
{
    //?
    public function countComments(Post $post)
    {
        $count = $post->comments()->count();
        return response()->json(['count' => $count]);
    }

    public function getPostComments($postId)
    {
        $postComments = Comment::where('post', 1)
            ->where('post_id', $postId)
            ->orderBy('created_at', 'desc')
            ->get();
        
        return response()->json($postComments);
    }

    public function getCommentReplies($commentId)
    {
        $commentReplies = Comment::where('post', 0)
            ->where('post_id', $commentId)
            ->orderBy('created_at', 'desc')
            ->get();
        
        return response()->json($commentReplies);
    }

    public function addComment(Request $request)
    {
        $validated = $request->validate([
            'post_id'  => 'required|integer',
            'post'     => 'required|boolean',
            'comment'  => 'required|string',
            'user_id'  => 'required|integer',
        ]);

        $comment = ":(";

        return response()->json($comment, 201);
    }
}