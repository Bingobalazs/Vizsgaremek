<?php

namespace App\Http\Controllers;

use App\Models\Lakas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LakasController extends Controller
{
    public function create()
    {
        $lakasok = Lakas::all();
        $koordinatak = DB::table('lakas')->get();

        return view('lakas', compact('lakasok', 'koordinatak'));
    }

    public function store(Request $request)
    {
        Lakas::create([
            'e' => $request->e,
            'l' => $request->l,
        ]);

        return redirect()->route('lakas')->with('success', 'Adatok sikeresen mentve!');
    }

    public function torles($e, $l)
    {
        DB::table('lakas')
            ->where('e', $e)
            ->where('l', $l)
            ->delete();

        return response()->json(['message' => 'Sikeres törlés!']);
    }
}

?>