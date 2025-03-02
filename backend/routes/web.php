<?php

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AutoController;
use App\Http\Controllers\FriendsController;
use App\Http\Controllers\SiteController;
use App\Http\Controllers\NewPasswordController;
use App\Http\Controllers\testAPIxController;


/*Route::controller(AuthController::class)->group(function () {
    Route::get('/login', 'LogView')->name('log');
    Route::post('/login', 'Log');
    Route::get('/register', 'RegView')->name('reg');
    Route::post('/register', 'Reg');
    Route::post('/logout', 'Logout')->name('logout');
});*/


// Felhasználókezlés
Route::controller(AuthController::class)->group(function () {
    Route::get('/','index')->name('index');

    Route::get('/login','login')->name('login');
    Route::post('/login','loginPost')->name('login.post');

    // Regisztráció
    Route::get('/registration','registration')->name('registration');
    Route::post('/registration','registrationPost')->name('registration.post');
    Route::post('/registration2','registrationPostCode')->name('registration.code');

    // Kijelentkezés
    Route::get('/logout','logout')->name('logout');



    // Elfelejtett jelszó
        // Link kérés
        Route::get('/forgot-password',  'forgot')->name('password.request');
        Route::post('/forgot-password',  'resetmail')->name('password.email');

        // Jelszó visszaállítás

    // Profil és módosítás
    Route::get('/profil', 'profil')->name('profil');
    Route::post('/modifyprofile', 'modifyprofile')->name('modifyprofile')->middleware('auth');



});

// Jelszó reset
Route::get('/reset-password/{token}', [NewPasswordController::class, 'create'])->name('password.reset');
Route::post('/reset-password', [NewPasswordController::class, 'store'])->name('password.update');






Route::controller(AutoController::class)->group(function () {

    // Hirdetés hozzáadása
    Route::post('/add','addPost')->name('add.post');
    Route::get('/add',   'add')->name('add');
    // Hirdetések listázása
    Route::get('/list','List')->name('list');
    //
    Route::get('/modify','getModify')->name('modify');
    Route::post('/modify','setModify')->name('modify.post');
    // Saját hirdetések
    Route::get('/own','ownAds')->name('own');
    Route::delete('own/delete', 'delete')->name('own.delete');
    // Konkrét autó
    Route::get('cars/{id}', 'show')->name('show');
    // like, comment
    Route::post('/cars/{id}/comment', 'store')->name('comment');

    Route::get('/like/{id}', 'like')->name('like');

    Route::get('/getchat', 'getchat')->name('getchat');
    Route::post('/postchat', 'postchat')->name('postchat');


});
Route::controller(FriendsController::class)->group(function () {

    Route::post('/jeloles/{id}', 'jeloles')->name('jeloles');
    Route::get('/friend_req', 'friend_req')->name('friend_req');
    Route::post('/accept/{id}', 'accept')->name('accept');

    // Felhasználók listázása
    Route::get('/users', 'users')->name('users');
    Route::get('/view/users', 'viewUsers')->name('users');

});



////////


Route::controller(testAPIxController::class)->group(function () {
    Route::get('/testapi','testAPI')->name('testapi');
    Route::post('/testapi','postTest')->name('testapi.post');

});


Route::post('/test/login', function (Request $request) {
    $credentials = $request->validate([
        'email' => 'required|email',
        'password' => 'required'
    ]);

    if (!Auth::attempt($credentials)) {
        return response()->json([
            'message' => 'Invalid credentials'
        ], 401);
    }

    $user = User::where('email', $request->email)->first();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'access_token' => $token,
        'token_type' => 'Bearer',
    ]);
});


use App\Http\Controllers\IdentiController;



// Public profile routes
Route::get('/identicard/{username}', [IdentiController::class, 'share'])->name('profile.beam');

// Connect with user
Route::get('/connect/{username}', [IdentiController::class, 'connect'])->name('connect');
