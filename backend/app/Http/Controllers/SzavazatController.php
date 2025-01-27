<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Szavazat;
use Exception;
use Illuminate\Support\Facades\DB;

class SzavazatController extends Controller
{
    public function Szavazas($id)
    {
        $szavazatok = Szavazat::all()->toArray();
        $max = DB::table('szavazas')->max('szavazat');
        $min = DB::table('szavazas')->min('szavazat');
        $time = DB::table('szavazas')->min('updated_at');
        return view('Szavazas', ['szavazatok' => $szavazatok, 'max' => $max, 'min' => $min, 'id' => $id, 'time' => $time]);
    }

    public function SzavazatKuldes($id)
    {
        date_default_timezone_set('Europe/Budapest');
        $szavazat = Szavazat::find($id);
        $legutolsoSzavazas = $szavazat->updated_at;
        $jelenlegiIdo = date('Y-m-d H:i:s');
        $idoKulonbseg = strtotime($jelenlegiIdo) - strtotime($legutolsoSzavazas);
        if ($idoKulonbseg>10)
        {
            $szavazat->szavazat++;
            $szavazat->save();
        }

        return $this->Szavazas($id);
    }
}