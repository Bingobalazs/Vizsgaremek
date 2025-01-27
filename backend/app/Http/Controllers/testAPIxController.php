<?php
    namespace App\Http\Controllers;

    use Illuminate\Http\Request;
    use App\Models\api;

    class testAPIx extends Controller
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
    }
?>