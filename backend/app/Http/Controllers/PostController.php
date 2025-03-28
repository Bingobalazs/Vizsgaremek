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

        // Get the page number from the request (default to 1 if not provided)
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 10; // Number of posts per page
        $offset = ($page - 1) * $perPage;

        // Fetch the IDs of posts the user has seen from the views table
        $seenPostIds = View::where('user_id', $user->id)->pluck('post_id');

        // Fetch unseen posts first, limited by pagination
        $unseenPosts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->whereNotIn('id', $seenPostIds)
            ->orderBy('created_at', 'desc')
            ->skip($offset)
            ->take($perPage)
            ->get();

        // If there aren't enough unseen posts, fetch seen posts to fill the remaining slots
        if ($unseenPosts->count() < $perPage) {
            $remaining = $perPage - $unseenPosts->count();
            $seenPosts = Post::with(['user' => function($query) {
                $query->select('id', 'name');
            }])
                ->orderBy('created_at', 'desc')
                ->skip($offset)
                ->take($remaining)
                ->get();

            $posts = $unseenPosts->merge($seenPosts);
        } else {
            $posts = $unseenPosts;
        }

        $posts = $posts->map(function ($post) use ($seenPostIds) {
            $post->is_unseen = !$seenPostIds->contains($post->id);
            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();

            // Uncomment when comments and views are implemented
            // $post->comment_count = $post->comments()->count();
            // $post->view_count = $post->views()->count();

            return $post;
        });

        // Check if there are more posts to fetch
        $hasMore = Post::count() > $page * $perPage;

        return response()->json([
            'posts' => $posts,
            'page' => $page, // Return the current page for tracking
            'has_more' => $hasMore, // True if there are more posts to load
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

    public function markSeen($post)
    {

        $user = Auth::user();

        View::create([
            'user_id' => $user->id,
            'post_id' => $post,
        ]);

        return response()->json([
            'post_id' => $post,
            'user_id' => $user->id,
        ]);


    }

    public function ownPosts()
    {
        $user = Auth::user();
        $user_id = $user->id;
        $posts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get();


    }
    public function FriendPosts($user_id)
    {
        $posts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get();


    }

}
