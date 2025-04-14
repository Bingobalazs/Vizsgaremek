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
            ->with('user')
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
            'post_id' => 'required|integer',
            'comment' => 'required|string',
            'user_id' => 'required|integer',
        ]);

        $comment = Comment::create($validated);

        return response()->json([
            'message' => 'Jó lesz!4!',
            'comment' => $comment,
        ], 201);
    }
}