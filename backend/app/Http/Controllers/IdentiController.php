<?php

namespace App\Http\Controllers;

use App\Models\Identicard;
use Illuminate\Http\Request;
use App\Models\User;

class IdentiController extends Controller
{


    public function hasIdenticard(Request $request){
        $user = auth()->user();

        if(Identicard::where('user_id', $user->id)->exists()){
            return response()->json(['exists' => true]);
        }return response()->json(['exists' => false]);

    }
    public function share($username)
    {
        $user = Identicard::where('username', $username)->firstOrFail();
        return view('blabber.identicard',  compact('user'));
    }

    public function get($username)
    {
        $user = auth()->user();

        $info = Identicard::where('user_id', $user->id)->firstOrFail();
        return response()->json($info);
    }

    public function update(Request $request)
    {
        $user = auth()->user();

        $validatedData = $request->validate([
            'username' => 'nullable|string|max:255',
            'email' => 'nullable|string|max:255',
            'name' => 'nullable|string|max:255',
            'profile_picture' => 'nullable|string|max:255',
            'cover_photo' => 'nullable|string|max:255',
            'bio' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'birthday' => 'nullable|date',
            'pronouns' => 'nullable|string|max:50',
            'relationship_status' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:20',
            'messaging_apps' => 'nullable|json',
            'website' => 'nullable|string|max:255',
            'social_handles' => 'nullable|json',
            'current_workplace' => 'nullable|string|max:255',
            'job_title' => 'nullable|string|max:255',
            'previous_workplaces' => 'nullable|json',
            'education' => 'nullable|json',
            'skills' => 'nullable|array',
            'skills.*' => 'string',
            'certifications' => 'nullable|json',
            'languages' => 'nullable|json',
            'portfolio_link' => 'nullable|string|max:255',
            'hobbies' => 'nullable|array',
            'hobbies.*' => 'string',
            'theme_primary_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_accent_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_bg_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_text_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'profile_visibility' => 'nullable|in:public,private',
        ]);

        $identicard = Identicard::where('user_id', $user->id)->firstOrFail();

        $identicard->update($validatedData);

        return response()->json(['message' => 'Identicard updated successfully', 'data' => $identicard]);
    }



    public function store(Request $request)
    {
        $user = auth()->user();

        $validatedData = $request->validate([
            'username' => 'nullable|string|max:255',
            'email' => 'nullable|string|max:255',
            'name' => 'nullable|string|max:255',
            'profile_picture' => 'nullable|string|max:255',
            'cover_photo' => 'nullable|string|max:255',
            'bio' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'birthday' => 'nullable|date',
            'pronouns' => 'nullable|string|max:50',
            'relationship_status' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:20',
            'messaging_apps' => 'nullable|json',
            'website' => 'nullable|string|max:255',
            'social_handles' => 'nullable|json',
            'current_workplace' => 'nullable|string|max:255',
            'job_title' => 'nullable|string|max:255',
            'previous_workplaces' => 'nullable|json',
            'education' => 'nullable|json',
            'skills' => 'nullable|array',
            'skills.*' => 'string',
            'certifications' => 'nullable|json',
            'languages' => 'nullable|json',
            'portfolio_link' => 'nullable|string|max:255',
            'hobbies' => 'nullable|array',
            'hobbies.*' => 'string',
            'theme_primary_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_accent_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_bg_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'theme_text_color' => 'nullable|string|regex:/^#([A-Fa-f0-9]{6})$/',
            'profile_visibility' => 'nullable|in:public,private',
        ]);

        $identicard = Identicard::create(array_merge($validatedData, ['user_id' => $user->id]));

        return response()->json(['message' => 'Identicard created successfully', 'data' => $identicard]);
    }
}
