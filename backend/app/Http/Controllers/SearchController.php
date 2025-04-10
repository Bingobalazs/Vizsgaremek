<?php

namespace App\Http\Controllers;

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

class SearchController extends Controller
{

    public function search($query)
    {
        //$query = $request->input('query');


        $posts = $query
            ? Post::with('user:id,name')
                ->where('content', 'like', "%{$query}%")
                ->paginate(10)
            : Post::paginate(10);
        //TODO: felhasználó nevének hozzáadása outputhoz, hogy a frontend úgy mutassa a posztokat

// Keep the pagination data by storing it separately
        $paginationData = $posts->toArray();
        $paginationMeta = [
            'current_page' => $paginationData['current_page'],
            'last_page' => $paginationData['last_page'],
            'per_page' => $paginationData['per_page'],
            'total' => $paginationData['total'],
            'links' => $paginationData['links'] ?? null,
        ];

// Now transform the items
        $transformedItems = $posts->getCollection()->map(function ($post) {
            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();
            return $post;
        });

// Replace the original collection with the transformed items
        $posts->setCollection($transformedItems);

        $users = $query
            ? User::where('name', 'like', "%{$query}%")->paginate(10)
            : User::paginate(10);

        return response()->json([
            'posts' => $posts,
            'users' => $users,
        ]);
    }
}
