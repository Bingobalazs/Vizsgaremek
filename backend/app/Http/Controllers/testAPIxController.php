<?php
    namespace App\Http\Controllers;

    use Illuminate\Http\Request;
    use App\Models\api;
    use Illuminate\Support\Facades\Auth;

    class testAPIxController extends Controller
    {
        private function CheckAPIKey($key)
        {
            $user = api::where('apikey', $key)->first();
            return $user;
        }

        public function testAPI()
        {
            if(isset($_GET['apiKey']))
            {
                $felhasznalo = $this->CheckAPIKey($_GET['apiKey']);
                if($felhasznalo != null)
                {
                    return response()->json(['message' => $felhasznalo->name], 200);
                }
                else return response()->json(['error' => 'Invalid API key'], 403);
            }
            else return response()->json(['error' => 'Missing API key'], 403);
        }

        public function postTest(Request $request)
        {
            $request->validate([
                'email' => 'required',
                'password' => 'required'
            ]);

            $data = $request->only('email', 'password');
            try {
                if (Auth::attempt($data))
                {
                    return Auth::getSession();
                }
                return "2111111";

            } catch (Exception $e) {
                return $e->getMessage();
            }
        }

    }
?>
