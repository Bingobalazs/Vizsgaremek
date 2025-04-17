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

    public function login(LoginRequest $loginRequest)
    {

        // Validate
        $loginRequest->validated();

        // check user
        $user = User::where('email', $loginRequest->email)->first();
        if (!$user || !Hash::check($loginRequest->password, $user->password)) {
            return response()->json([
                'error' => 'Password or email incorrect'
            ], 401);
        }






        // Create token with abilities/scopes if needed
        $token = $user->createToken('auth', ['server:auth'])->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'message' => 'Successfully logged in'
        ], 200);
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
        $data['pfp_url'] = "uploads/1744789807_default_profil.png";


        $to = $data['email'];
        $subject = "Regisztrációs kód";
        $message = "
                <body style='background-color: #0b203b'>

                    <h1>Üdv a Blabberen!</h1>
                    <p>A regisztráció véglegesítéséhez szükséged lesz az alábbi kódra:</p>

                    <h2 style=' text-align: center; color: #fd204d;'>
                   <strong>{$data['code']}</strong></h2>

                    <p>Köszönjük a regisztrációt!</p>
                    <a href='kovacscsabi.moriczcloud.hu/blabber'>Tovább a blabberre</a>
                </body>
                    ";

        $headers = 'From: blabber@moriczcloud.com' . "\r\n" .
            'Content-Type: text/html; charset=UTF-8'. "\r\n" .
            'X-Mailer: PHP/' . phpversion();

        mail($to, $subject, $message, $headers);

        User::create($data);

        return response()->json($data);
    }

    public function confirm(Request $request)
    {
        // Validate the incoming request data
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string',
        ]);

        // Extract email and code from the request
        $email = $request->input('email');
        $code = $request->input('code');

        // Find the user by email
        $user = User::where('email', $email)->first();

        // Check if user exists
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Check if account is already confirmed (code is null)
        if ($user->code === null) {
            return response()->json(['message' => 'Account already confirmed'], 200);
        }

        // Verify the provided code matches the stored code
        if ($user->code !== $code) {
            return response()->json(['message' => 'Invalid confirmation code'], 400);
        }

        // Confirm the account by clearing the code
        $user->code = null;
        $user->save();

        // Return success response
        return response()->json(['message' => 'Account confirmed successfully'], 200);
    }

    public function updateName(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();
        $user->name = $request->name;
        $user->save();

        return response()->json([
            'message' => 'Name updated successfully',
            'user' => $user
        ]);
    }

    /**
     * Update the user's password.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updatePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        // Check if current password is correct
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Current password is incorrect',
            ], 422);
        }

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'message' => 'Password updated successfully'
        ]);
    }
}
