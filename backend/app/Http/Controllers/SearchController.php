<?php

namespace App\Http\Controllers;

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

class SearchController extends Controller
{

    public function search(Request $request)
    {
        $queryTerm = $request->input('query');

        $posts = $queryTerm
            ? Post::where('content', 'like', "%{$queryTerm}%")->paginate(10)
            : Post::paginate(10);

        $users = $queryTerm
            ? User::where('name', 'like', "%{$queryTerm}%")->paginate(10)
            : User::paginate(10);

        return response()->json([
            'posts' => $posts,
            'users' => $users,
        ]);
    }
}