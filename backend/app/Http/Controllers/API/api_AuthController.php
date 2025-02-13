<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;

use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\Rules;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;


// Eloquent
use App\Models\User;

class api_AuthController extends Controller
{

    public function login(LoginRequest $loginRequest, Request $request)
    {

        // Validate
        $loginRequest->validated();

        // check user
        $user = User::where('email', $loginRequest->email)->first();
        if (!$user || !Hash::check($loginRequest->password, $user->password)) {
            return response()->json([
                'error' => 'Password or email incorrect'
            ]);
        }






        // Create token with abilities/scopes if needed
        $token = $user->createToken('auth', ['server:auth'])->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'message' => 'Successfully logged in'
        ]);
    }


    public function logout(Request $request)
    {
        // Revoke all tokens...
        $request->user()->tokens()->delete();

        // Or revoke the token that was used for authentication
        // $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }


    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    public function registration(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required'
        ]);

        $data['name'] = $request->name;
        $data['email'] = $request->email;
        $data['password'] = Hash::make($request->password);
        $data['code'] = rand(100000, 999999);


        $to = $data['email'];
        $subject = "Regisztrációs kód";
        $message = "

                    <h1>Üdv a Hazsnáltautónál!</h1>
                    <p>A regisztráció véglegesítéséhez szükséged lesz az alábbi kódra:</p>

                    <h2 style=' text-align: center; color: #007FFF;'>
                   <strong>{$data['code']}</strong></h2>

                    <p>Köszönjük a regisztrációt!</p>
                    <a href='kovacscsabi.moriczcloud.hu'>Tovább a hazsnáltautóra</a>
                    ";

        $headers = 'From: anyad@sex.com' . "\r\n" .
            'Content-Type: text/html; charset=UTF-8'. "\r\n" .
            'X-Mailer: PHP/' . phpversion();

        mail($to, $subject, $message, $headers);



        return view('code', compact('data'));
    }
}
