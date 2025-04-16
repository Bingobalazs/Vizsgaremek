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
        $posts = $query
            ? Post::with('user:id,name')
                ->where('content', 'like', "%{$query}%")
                ->paginate(10)
            : Post::paginate(10);

        // A pagination adatokat külön tároljuk
        $paginationData = $posts->toArray();
        $paginationMeta = [
            'current_page' => $paginationData['current_page'],
            'last_page'    => $paginationData['last_page'],
            'per_page'     => $paginationData['per_page'],
            'total'        => $paginationData['total'],
            'links'        => $paginationData['links'] ?? null,
        ];

        // Átalakítjuk az elemeket, hogy beépítsük az egyedi tulajdonságokat
        $transformedItems = $posts->getCollection()->map(function ($post) {
            $post->is_liked   = $post->isLikedByUser(Auth::id());
            $post->like_count = $post->likes()->count();
            return $post;
        });

        // Lecseréljük az eredeti kollekciót az átalakított kollekcióra
        $posts->setCollection($transformedItems);

        // A bejelentkezett felhasználó kizárása a felhasználók listájából:
        $usersQuery = User::where('id', '!=', Auth::id());

        if ($query) {
            $usersQuery->where('name', 'like', "%{$query}%");
        }
        $users = $usersQuery->paginate(10);

        return response()->json([
            'posts' => $posts,
            'users' => $users,
        ]);
    }

}
