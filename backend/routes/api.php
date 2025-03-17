<?php
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\API\api_AuthController;
use App\Http\Controllers\AutoController;



Route::get('/p', [AutoController::class, 'p']);

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


    Route::controller(api_AuthController::class)->group(function () {

        Route::post('/logout', 'logout');
        Route::get('/user', 'user');

    });

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




