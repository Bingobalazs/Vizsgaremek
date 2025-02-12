<?php
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\API\api_AuthController;




Route::controller(api_AuthController::class)->group(function () {

    Route::post('/login2', 'login2');
    Route::post('/registration', 'registration');

    //Route::post('/register', 'Reg');
    //Route::post('/logout', 'Logout')->name('logout');
});
Route::middleware('auth:sanctum')->group(function () {
    Route::controller(api_AuthController::class)->group(function () {

        Route::post('/logout', 'logout');
        Route::get('/user', 'user');

    });
});


Route::post('/tokens/create', function (Request $request) {
    $token = $request->user()->createToken($request->token_name);

    return ['token' => $token->plainTextToken];
});
