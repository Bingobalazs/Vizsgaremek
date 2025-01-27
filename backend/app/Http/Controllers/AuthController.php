<?php

namespace App\Http\Controllers;

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
use App\Models\Auto;

class AuthController extends Controller
{
    public function index()
    {
        /*$cars = Auto::all();
        return view('index', compact('cars'));*/
        $id = Auth::id(); // Bejelentkezett felhasználó azonosítója

        /*$data = DB::table('Auto')
        ->leftJoin('views', function ($join) use ($userId) {
            $join->on('Auto.id', '=', 'views.auto_id')
                ->where('views.user_id', '=', $userId);
        })
        ->select('Auto.*', DB::raw('views.id as viewed'), DB::raw('views.updated_at as date'))
        ->get();*/
        $data = DB::table('Auto')
                ->join('users', 'users.id', '=', 'Auto.user_id')
                ->leftJoin('views', function ($join) use ($id) {
                    $join->on('views.auto_id', '=', 'Auto.id')
                         ->where('views.user_id', '=', $id);
                })
                ->where('users.public', 1)
                ->select('Auto.id as id', 'Auto.marka', 'Auto.modell', 'Auto.created_at', 'Auto.kep_url', 
                    DB::raw('IF(views.id IS NULL, false, true) as viewed'))  // Ha nincs rekord a views táblában, akkor false (nem látta), egyébként true (látta)
                ->get();

        return view('index', compact('data'));
    }

    public function login()
    {
        return view('login');
    }

    public function registration()
    {
        return view('registration');
    }

    public function loginPost(Request $request)
    {
        $request->validate([
            'email' => 'required',
            'password' => 'required'
        ]);

        $data = $request->only('email', 'password');

        if (Auth::attempt($data))
        {
            return redirect()->intended(route('index'))->with("success", "Hot Sex");
        }
        return redirect(route('login'))->with("error", "Naha");
    }

    public function RegistrationPost(Request $request)
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


        /*$user = User::create($data);

        if (!$user)
        {
            return redirect(route('registration'))->with("error", "Naha");
        }
        return redirect(route('login'))->with("success", "Hot Sex");*/
        return view('code', compact('data'));
    }

    public function RegistrationPostCode(Request $request)
    {
        /*
            Clean coding Á'la Csaba: code meg code2

            code = generált code, code2=user input code ha jól értem
        */

        $request->validate([
            'code2' => 'required'
        ]);

        $data = json_decode($request->input('data'), true);
        $data['code2'] = $request->code2;


        // Kódok ellenőrzése
        if ($data['code'] == $data['code2'])
        {
            unset($data['code'], $data['code2']);
            $user = User::create($data);

            if (!$user)
            {
                return redirect(route('registration'))->with("error", "Tesó még én sem tudom mi a hiba. Ne mond már el senkinek, jó?");
                                                                        // Geci nagy szerencséd volt h ezzel nem találkoztam -B
            }
            return redirect(route('login'))->with("success", "Fiók sikeresen létrehozva");
        }
        return redirect(route('registration'))->with("error", "Hiba a hitelesítés során. Nem egyezik az ellenőrző kód");
    }

    public function logout()
    {
        Session::flush();
        Auth::logout();
        return redirect(route('login'));
    }

    public function add()
    {
        return view('add');
    }



    public function forgot()
    {
        return view('forgot-password');
    }

    // Jelszó link e-mail küldés
    public function resetmail(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            Log::error('User not found with email: ' . $request->email);
        }


        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            Log::info('Password reset link sent for email: ' . $request->email);
        } else {
            Log::error('Failed to send password reset link for email: ' . $request->email);
            Log::error('Status: ' . $status);
        }

        return $status === Password::RESET_LINK_SENT
            ? back()->with(['status' => __($status)])
            : back()->withErrors(['email' => __($status)]);
    }


    public function createToken($token)
    {
        return view('reset-password', ['token' => $token]);
    }

    // Új jelszó
    public function updatePassword(Request $request)
    {


        $validatedData = $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => ['required', 'confirmed', Rules\Password::min(4)],
        ]);



        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {


                $user->forceFill([
                    'password' => Hash::make($password),
                ])->save();



                $user->setRememberToken(Str::random(60));
            }
        );



        if ($status === Password::PASSWORD_RESET) {

            return redirect()->route('login')->with('status', __($status));
        } else {

            return back()->withErrors(['email' => [__($status)]]);
        }

    }
}

