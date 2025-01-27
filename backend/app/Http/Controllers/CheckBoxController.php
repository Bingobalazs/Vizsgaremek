<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CheckBoxController extends Controller
{
    public function tablazat()
    {
        $data = DB::table('checkbox')->get();
        $t = [];
        foreach ($data as $d)
        {
            $t[$d->oszlop][$d->sor] = $d->ertek;
        }
        return view('checkboxtablazat');
    }

    public function tablazatMentes ($sor, $oszlop, $ertek)
    {
        DB::table('checkbox')->where('sor', $sor)->where('oszlop', $oszlop)->update(['ertek' => $ertek]);
    }
}