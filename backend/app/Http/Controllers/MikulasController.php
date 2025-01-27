<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Mikulas;
use Exception;
use Illuminate\Support\Facades\DB;

class MikulasController extends Controller
{
    public function Mikulas()
    {
        return view('Mikulas');
    }

    public function Csomag()
    {
        $csomag = csomag::all()->toArray();
        return view('Csomag', ['csomag' => $csomag]);
    }

    public function MikulasKuldes(Request $request)
    {
        $csomag = "";
        $ar = 0;
        if ($request->input('c') == "on")
        {
            $csomag .= "Csoki;";
            $ar += 350;
        }
        if ($request->input('r') == "on")
        {
            $csomag .= "Ropi;";
            $ar += 300;
        }
        if ($request->input('s') == "on")
        {
            $csomag .= "Szotyi;";
            $ar += 300;
        }
        if ($request->input('k') == "on")
        {
            $csomag .= "Kóla;";
            $ar += 450;
        }
        if ($request->input('g') == "on")
        {
            $csomag .= "Gumicukor;";
            $ar += 450;
        }
        $task = new Mikulas();
        $task->nev = $request->input('nev');
        $task->csomag = $csomag;
        $task->ar = $ar;
        $task->save();

        return view('Mikulas');
    }
}