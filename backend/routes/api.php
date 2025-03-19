<?php

use App\Http\Controllers\PostController;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\API\api_AuthController;
use App\Http\Controllers\AutoController;
use App\Http\Controllers\ChatController;


Route::get('/p', [AutoController::class, 'p']);

Route::controller(ChatController::class)->group(function () {
    
    Route::post('/postchat/{user_id}/{friend_id}/{chat}', 'postchat')->name('postchat');

});

Route::controller(api_AuthController::class)->group(function () {

    Route::post('/login', 'login');
    Route::post('/registration', 'registration');

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

    // Posztok CRUD
    Route::apiResource('posts', PostController::class);
        /*
         * GET /api/posts - List posts
         * POST /api/posts - Create a post
         * GET /api/posts/{id} - Show a post
         * PUT /api/posts/{id} - Update a post
         * DELETE /api/posts/{id} - Delete a post
         */

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

});




