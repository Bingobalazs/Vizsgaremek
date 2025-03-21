<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\View;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;


class PostController extends Controller
{
    // Get a paginated list of posts (e.g., a feed)
    public function index(Request $request)
    {
        // Get the authenticated user
        $user = Auth::user();

        // Fetch the IDs of posts the user has seen from the views table
        $seenPostIds = View::where('user_id', $user->id)->pluck('post_id');

        // Fetch up to 10 latest unseen posts
        $unseenPosts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->whereNotIn('id', $seenPostIds)
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get();

        // Initialize the posts collection with unseen posts
        $posts = $unseenPosts;

        // If fewer than 10 unseen posts, fetch seen posts to reach 10 total
        if ($unseenPosts->count() < 10) {
            $remaining = 10 - $unseenPosts->count();
            $seenPosts = Post::with(['user' => function($query) {
                $query->select('id', 'name');
            }])
                ->orderBy('created_at', 'desc')
                ->take($remaining)
                ->get();
            $posts = $unseenPosts->merge($seenPosts);
        }

        $posts = $posts->map(function ($post) use ($seenPostIds) {
            $post->is_unseen = !$seenPostIds->contains($post->id);
            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();

            /* EZ MAJD HA MEG LESZ CSINÁLVA
            $post->comment_count = $post->comments()->count();
            $post->view_count = $post->views()->count();
            */

            return $post;
        });

        // Prepare the JSON response with posts and a field for the frontend
        return response()->json([
            'posts' => $posts,
            'has_more' => $posts->count() == 10 // True if 10 posts returned, suggesting more may exist

        ]);
    }

    // Create a new post
    public function store(Request $request)
    {
        $validated = $request->validate([
            'content' => 'required|string',
            'media_url' => 'nullable|string',
        ]);

        $post = Post::create([
            'user_id' => Auth::id(),
            'content' => $validated['content'],
            'media_url' => $validated['media_url'] ?? null,
        ]);

        return response()->json($post, 201);
    }

    // Show a specific post
    public function show($id)
    {
        $post = Post::with('user')->findOrFail($id);
        return response()->json($post);
    }

    // Update a post
    public function update(Request $request, $id)
    {
        $post = Post::findOrFail($id);

        if ($post->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'content' => 'required|string',
            'media_url' => 'nullable|string',
        ]);

        $post->update($validated);

        return response()->json($post);
    }

    // Delete a post
    public function destroy($id)
    {
        $post = Post::findOrFail($id);

        if ($post->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $post->delete();

        return response()->json(['message' => 'Post deleted']);
    }
}
