<?php

namespace App\Http\Controllers;

use App\Models\webaruhaz;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class webaruhazController extends Controller
{
    public function create()
    {
        return view('create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Fájl feltöltése és elérési út mentése
        $imagePath = $request->file('image')->store('images', 'public');

        // Új bejegyzés mentése
        Image::create([
            'title' => $request->title,
            'path' => $imagePath,
        ]);

        return redirect()->route('images.index')->with('success', 'A kép sikeresen feltöltve.');
    }

    public function index()
    {
        $images = Image::all();
        return view('images.index', compact('images'));
    }

    public function show($id)
    {
        $image = Image::findOrFail($id);
        return view('images.show', compact('image'));
    }
}
