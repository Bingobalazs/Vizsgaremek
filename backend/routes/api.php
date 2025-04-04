<?php

use App\Http\Controllers\PostController;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\API\api_AuthController;
use App\Http\Controllers\AutoController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\FriendsController;
use App\Http\Controllers\LikeController;
use App\Http\Controllers\CommentController;


Route::get('/p', [AutoController::class, 'p']);

Route::controller(api_AuthController::class)->group(function () {

    Route::post('/login', 'login');
    Route::post('/registration', 'registration');
    Route::post('/registration/confirm', 'confirm');

});

// reverse - token
// a user elküldésével generál tokent, nem pedig fordívta
// jelenleg nincs használatban
Route::post('/tokens/create', function (Request $request) {
    $token = $request->user()->createToken($request->token_name);

    return ['token' => $token->plainTextToken];
});


// AUTH ONLY
Route::middleware('auth:sanctum')->group(function () {

    // AUTH
    Route::controller(api_AuthController::class)->group(function () {

        Route::post('/logout', 'logout');
        Route::get('/user', 'user');

    });

    Route::controller(ChatController::class)->group(function () {

        Route::post('/postchat/{user_id}/{friend_id}/{chat}', 'postchat')->name('postchat');
        Route::get('/getchat/{friend_id}', 'getchat')->name('getchat');
    });
    Route::get('stream-chat/{friend_id}/{lastMessageId}', [ChatController::class, 'streamChat']);

    Route::controller(FriendsController::class)->group(function () {

        Route::get('/friends', 'friends')->name('friends');
        Route::post('/jeloles/{id}', 'jeloles')->name('jeloles');
        Route::get('/friend_req', 'friend_req')->name('friend_req');
        Route::post('/accept/{id}', 'accept')->name('accept');

    });

    Route::controller(CommentController::class)->group(function () {

        Route::get('/getPostComments/{postId}', 'getPostComments')->name('getPostComments');
        Route::get('/getCommentReplies/{commentId}', 'getCommentReplies')->name('getCommentReplies');
        Route::post('/addComment', 'addComment')->name('addComment');

    });


    // Posztok CRUD
    Route::apiResource('posts', PostController::class);
        /*
         * GET /api/posts - List posts
         * POST /api/posts - Create a post
         * GET /api/posts/{id} - Show a post
         * PUT /api/posts/{id} - Update a post
         * DELETE /api/posts/{id} - Delete a post
         */
    Route::get('own/posts', [PostController::class, 'ownPosts']);
    Route::get('/friend/{user_id}/posts', [PostController::class, 'FriendPosts']);

    Route::post('view/{post}', [PostController::class, 'markSeen']);

    // Identicard
    Route::controller(\App\Http\Controllers\IdentiController::class)->group(function () {
        Route::get('/identicard/check', 'hasIdenticard'); // Ellenőrzi hogy a felhasználónak van e Identicard-ja
        Route::put('/identicard/update', 'update');
        Route::post('/identicard/add', 'store');
        Route::get('/identicard/get/', 'get');
        Route::get('/identicard/get/{username}', 'getByUserName');

    });

    Route::controller(\App\Http\Controllers\FriendsController::class)->group(function () {
       Route::get('/friends/{query}', 'search');

    });

    // Like
    Route::get('like/{post}', [LikeController::class, 'checkLike']); // Ellenőrzi hogy a felhasználó likeolta-e a posztot
    Route::post('like/{post}', [LikeController::class, 'toggleLike']); // Átállítja a like-ot


    /*  Nincs még commentcontroller
    Route::get('count/comment/{post}', [CommentController::class, 'countComments']);
    Route::get('count/like/{post}', [LikeController::class, 'countComments']);
         // Megszámolja a kommenteket egy adott poszt alatt (frontend like és komment counter badge-hez kell
    */

});




