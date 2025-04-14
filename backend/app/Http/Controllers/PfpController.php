<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class PfpController extends Controller
{
    public function update(Request $request)
    {
        $request->validate([
            'profile_picture' => 'required|image|mimes:jpeg,jpg,png,gif,svg|max:2048',
        ]);

        $user = Auth::user();

        $profile_picture = $request->file('profile_picture');
        $profile_picture_name = time().'_'.$profile_picture->getClientOriginalName();


        $imagePath = $profile_picture->storeAs('uploads', $profile_picture_name, 'my_files');


        $user->update([
            'pfp_url' => $imagePath
        ]);

        return response()->json(['message' => 'Profilkép sikeresen frissítve'], 200);
    }


}
