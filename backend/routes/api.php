<?php
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\API\api_AuthController;




Route::controller(api_AuthController::class)->group(function () {

    Route::post('/login', 'login');

    //Route::post('/register', 'Reg');
    //Route::post('/logout', 'Logout')->name('logout');
});
Route::middleware('auth:sanctum')->group(function () {
    Route::controller(api_AuthController::class)->group(function () {

        Route::post('/logout', 'logout');
        Route::get('/user', 'user');

    });
});
