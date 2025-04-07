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
            ? Post::where('content', 'like', "%{$query}%")->paginate(10)
            : Post::paginate(10);

        $users = $query
            ? User::where('name', 'like', "%{$query}%")->paginate(10)
            : User::paginate(10);

        return response()->json([
            'posts' => $posts,
            'users' => $users,
        ]);
    }
}