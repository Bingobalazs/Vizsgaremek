<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Etelek;
use Exception;
use Illuminate\Support\Facades\DB;

class EtelekController extends Controller
{
    function demo()
    {
        $etel = new Etelek();
        $etel->nev = "Harcsapaprikás";
        $etel->ar = 3500;
        $etel->save();
        return "Beírva";
    }

    function beiras($nev, $ar)
    {
        try
        {
            $rekord = Etelek::where('nev', $nev)->whereNot('ar', $ar)->first();
            if ($rekord != null)
            {
                Etelek::where('id', $rekord->id)->update([
                    'ar' => $ar
                ]);
                return "Az ár frissítve.";
            }
            else
            {
                $rekord = Etelek::where('nev', $nev)->where('ar', $ar)->first();

                if ($rekord == null)
                {
                    $etel = new Etelek();
                    $etel->nev = $nev;
                    $etel->ar = $ar;
                    $etel->kategoria = "idk";
                    $etel->szam = $szam;
                    $etel->save();
                    return "Adatbázisba írás kész.";
                }
                else
                {
                    return "Már van ilyen étel ilyen névvel.";
                }
            }
        }
        catch (Exception $e)
        {
            return $e;
        }
    }

    function posztolas(Request $request)
    {
        $adat = $request->all();
        $nev = $adat['nev'];
        $ar = $adat['ar'];
        $kategoria = $adat['kategoria'];

        $szam = (isset($adat['aa']) ? "1" : "0") . ";" . 
                (isset($adat['ab']) ? "1" : "0") . ";" . 
                (isset($adat['ac']) ? "1" : "0") . ";" . 
                (isset($adat['ad']) ? "1" : "0") . ";" . 
                (isset($adat['ba']) ? "1" : "0") . ";" . 
                (isset($adat['bb']) ? "1" : "0") . ";" . 
                (isset($adat['bc']) ? "1" : "0") . ";" . 
                (isset($adat['bd']) ? "1" : "0") . ";" . 
                (isset($adat['ca']) ? "1" : "0") . ";" . 
                (isset($adat['cb']) ? "1" : "0") . ";" . 
                (isset($adat['cc']) ? "1" : "0") . ";" . 
                (isset($adat['cd']) ? "1" : "0") . ";" . 
                (isset($adat['da']) ? "1" : "0") . ";" . 
                (isset($adat['db']) ? "1" : "0") . ";" . 
                (isset($adat['dc']) ? "1" : "0") . ";" . 
                (isset($adat['dd']) ? "1" : "0");

        return redirect("/etelbeir/$szam");
    }

    public function formMutat() {
        $kategoriak = DB::table('etelek')->select('kategoria')->groupBy('kategoria')->orderBy('kategoria')->get();
        $kat = [];
        foreach ($kategoriak as $k) {
            $kat[] = $k->kategoria;
        }
        return view('Etelek', ['kategoriak' => $kat]);
    }
}