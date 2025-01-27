<?php 

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Idojaras;
use Exception;

class IdojarasController extends Controller {

    public function lekerdez() {
        $osszes = Idojaras::all();
        return response()->json( $osszes);
    }
    
    function letrehoz($nev, $komment)
    {
        $New = new Idojaras();
        $New->nev = $nev;
        $New->komment = $komment;
        $New->save();
    }
}