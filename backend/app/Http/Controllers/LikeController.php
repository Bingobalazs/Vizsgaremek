<?php


namespace App\Http\Controllers;

    use App\Models\Post;
    use App\Models\Like;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

class LikeController extends Controller
{
    public function checkLike(Post $post)
    {
        $user = Auth::user();
        $isLiked = $post->isLikedByUser($user->id);
        return response()->json([
            'post_id' => $post->id,
            'user_id' => $user->id,
            'is_liked' => $isLiked,
        ]);
    }

    public function toggleLike(Post $post)
    {
        $user = Auth::user();
        $like = Like::where('user_id', $user->id)->where('post_id', $post->id)->first();
        if ($like) {
            $like->delete();
            $isLiked = false;
        } else {
            Like::create(['user_id' => $user->id, 'post_id' => $post->id]);
            $isLiked = true;
        }
        return response()->json([
            'post_id' => $post->id,
            'user_id' => $user->id,
            'is_liked' => $isLiked,
        ]);
    }
}

