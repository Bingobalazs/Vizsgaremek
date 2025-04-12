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

        // Get the page number from the request (default to 1)
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 10; // Number of posts per page
        $offset = ($page - 1) * $perPage;

        // Fetch seen post IDs
        $seenPostIds = View::where('user_id', $user->id)->pluck('post_id');

        // Fetch unseen posts first
        $unseenPosts = Post::with('user:id,name')
            ->whereNotIn('id', $seenPostIds)
            // **Added condition: Only fetch posts from users with public profiles**
            ->whereHas('user', function ($query) {
                $query->where('public', true); // Assuming 'is_public' is a boolean attribute in the users table
            })
            ->orderBy('created_at', 'desc')
            ->skip($offset)
            ->take($perPage)
            ->get();

        // If we don't have enough unseen posts, fetch seen posts to fill the remaining
        $unseenCount = $unseenPosts->count();
        if ($unseenCount < $perPage) {
            $remaining = $perPage - $unseenCount;

            // **Fix: Correct offset for seen posts**
            $seenOffset = max(0, $offset - Post::whereNotIn('id', $seenPostIds)->count());

            $seenPosts = Post::with('user:id,name')
                ->whereIn('id', $seenPostIds)
                // **Added condition: Only fetch posts from users with public profiles**
                ->whereHas('user', function ($query) {
                    $query->where('public', true); // Same condition here
                })
                ->orderBy('created_at', 'desc')
                ->skip($seenOffset)
                ->take($remaining)
                ->get();

            $posts = $unseenPosts->merge($seenPosts);
        } else {
            $posts = $unseenPosts;
        }

        // Map additional properties
        $posts = $posts->map(function ($post) use ($seenPostIds) {
            $post->is_unseen = !$seenPostIds->contains($post->id);
            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();

            return $post;
        });

        // Check if more posts exist
        $totalPosts = Post::whereHas('user', function ($query) {
            $query->where('public', true); // **Added condition here too**
        })->count();
        $hasMore = ($offset + $perPage) < $totalPosts;

        return response()->json([
            'posts' => $posts,
            'page' => $page,
            'has_more' => $hasMore
        ]);
    }





    // Create a new post
    public function store(Request $request)
    {
        
        $validated = $request->validate([
            'content' => 'required|string',
            'media_url' => 'image|mimes:jpeg,png,jpg,gif|max:5048', // max 5MB
        ]);
        if (!$validated) {
            return response()->json([
                'error' => 'Invalid request',
                'messages' => $request->errors()->all()
            ], 422);
        }

/*
        $postModel = new Post();
        \Log::info('Attempting to save to table: ' . $postModel->getTable()); // Check Laravel log
        dd('Attempting to save to table:', $postModel->getTable()); // Or die and dump
*/

        if ($request->hasFile('media_url')) {
            $file = $request->file('media_url');
            $filename = time().'_'.$file->getClientOriginalName();
            $imagePath = $file->storeAs('uploads', $filename, 'my_files');

        } else $imagePath=null;





        $post = Post::create([
            'user_id' => Auth::id(),
            'content' => $validated['content'],
            'media_url' => $imagePath,
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

    public function ownPosts(Request $request)
    {

        // Get the page number from the request (default to 1 if not provided)
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 10; // Number of posts per page
        $offset = ($page - 1) * $perPage;


        $user = Auth::user();
        $user_id = $user->id;
        $posts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->skip($offset)
            ->take($perPage)
            ->get();
        // Check if more posts exist
        $totalPosts = Post::count();
        $hasMore = ($offset + $perPage) < $totalPosts;
        $posts = $posts->map(function ($post) {

            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();

            return $post;
        });
        return response()->json([
            'posts' => $posts,
            'page' => $page, // Return the current page for tracking
           'has_more' => $hasMore, // True if there are more posts to load


        ]);
    }
    public function FriendPosts(Request $request, $user_id)
    {
        // Get the page number from the request (default to 1 if not provided)
        $page = max(1, (int) $request->input('page', 1));
        $perPage = 10; // Number of posts per page
        $offset = ($page - 1) * $perPage;


        $user = Auth::user();
        $posts = Post::with(['user' => function($query) {
            $query->select('id', 'name');
        }])
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->skip($offset)
            ->take($perPage)
            ->get();
        // Check if more posts exist
        $totalPosts = Post::count();
        $hasMore = ($offset + $perPage) < $totalPosts;
        return response()->json([
            'posts' => $posts,
            'page' => $page, // Return the current page for tracking
            'has_more' => $hasMore, // True if there are more posts to load


        ]);


    }

}
