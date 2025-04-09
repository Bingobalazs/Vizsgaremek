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
            ? Post::where('content', 'like', "%{$query}%")
                ->paginate(10)
            : Post::paginate(10);
        /*
        $posts = $query
            ? Post::with('user:id,name')
                ->where('content', 'like', "%{$query}%")
                ->paginate(10)
            : Post::paginate(10);

        $posts = $posts->map(function ($post) {

            $post->is_liked = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();

            return $post;
        });
        */

        $users = $query
            ? User::where('name', 'like', "%{$query}%")->paginate(10)
            : User::paginate(10);

        return response()->json([
            'posts' => $posts,
            'users' => $users,
        ]);
    }
}
