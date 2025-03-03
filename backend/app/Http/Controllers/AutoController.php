<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
// Eloquent
use App\Models\Auto;

class AutoController extends Controller
{

    public function getchat($user_id, $friend_id)
    {
        $messages = DB::table('chats')
        ->where(function ($query) use ($user_id, $friend_id) {
            $query->where('from_id', $user_id)
                  ->where('to_id', $friend_id);
        })
        ->orWhere(function ($query) use ($user_id, $friend_id) {
            $query->where('from_id', $friend_id)
                  ->where('to_id', $user_id);
        })
        ->orderBy('created_at', 'asc')
        ->get();

        return "response()->json()";

    }

    public function postchat($user_id, $friend_id)
    {
        return "chat";
    }

    public function List()
    {
        $autok= Auto::all();
        return view('autok', compact('autok'));
    }// view return

    // Post hozzáadás
    public function add()
    {
        //hozzáadás form
        return view('add');
    }// view return
    public function addPost(Request $request)
    {
        // Validálás
        $request->validate([
            'marka' => 'required|string|max:255',
            'modell' => 'required|string|max:255',
            'evjarat' => 'required|integer|min:1886|max:' . date('Y'),
            'kilometer' => 'required|integer',
            'meghajtas' => 'required|string|in:Benzin,Dízel,Elektromos,Hibrid',
            'allapot' => 'required|string|in:Újszerű,Jó,Használt,Sérült',
            'ar' => 'required|numeric',
            'kep_url' => 'image|mimes:jpeg,png,jpg,gif|max:5048', // max 5MB
            'kontakt_info' => 'required|string|max:255',
            'leiras' => 'required|string',
        ]);

        // Kép feltöltése
        if ($request->hasFile('kep_url')) {
            $file = $request->file('kep_url');
            $filename = time().'_'.$file->getClientOriginalName();
            $imagePath = $file->storeAs('uploads', $filename, 'my_files');


        }
        else{
        $imagePath="noimage.jpeg";
        }

        // Új autó létrehozása
        $auto = Auto::create([
            'marka' => $request->marka,
            'modell' => $request->modell,
            'evjarat' => $request->evjarat,
            'kilometer' => $request->kilometer,
            'meghajtas' => $request->meghajtas,
            'allapot' => $request->allapot,
            'ar' => $request->ar,
            'kep_url' => $imagePath, // Kép URL mentése
            'kontakt_info' => $request->kontakt_info,
            'leiras' => $request->leiras,
            'user_id' => Auth::id(),
        ]);

        $authController = new AuthController();
        return redirect()->route('index');

    }

    public function setModify(Request $request)
    {
        // Ellenőrizzük, hogy van-e id paraméter
        if (!$request->has('id')) {
            dd($request->all());
            //return redirect()->back()->with('error', 'Az autó azonosítója hiányzik!');
        }

        // Megkeressük az adatbázisban az autót az azonosító alapján
        $auto = Auto::find($request->id);
        if (!$auto) {
            dd($auto);
            //return redirect()->back()->with('error', 'Az autó nem található az adatbázisban!');
        }

        // Összegyűjtjük a frissítendő mezőket
        $modlog = '';
        $updatableFields = ['marka', 'modell', 'evjarat', 'kilometer', 'meghajtas', 'allapot', 'ar', 'kontakt_info', 'leiras'];

        foreach ($updatableFields as $field) {
            if ($request->filled($field)) {
                Auto::find( $request->id)->update([$field => $request->input($field)]);

                $modlog .= $field . ': ' . $request->input($field) . '; ';
            }
        }

        // Ha volt módosítás, mentjük az adatokat
        if ($modlog) {
            $auto->save();
            //dd($modlog);
            return redirect()->back()->with('success', 'A kijelölt elemek módosítva lettek: ' . $modlog);
        }

        // Ha nem történt módosítás
        return redirect()->back()->with('info', 'Nem történt módosítás.');

    }
    public function getModify(Request $request)
    {
        $auto =  Auto::find($request->id);
        return view('modify', compact('auto'));
    }// view return


    public function ownAds()
    {
        $userId = Auth::id();

        $data = Auto::where('user_id', $userId)->get();

        return view('ownAds', compact('data'));
    }// view return

    public function delete(Request $request)
    {
        if ($request->has('ids') && is_array($request->ids)) {

           $autos= Auto::whereIn('id', $request->ids);

           foreach ($autos as $auto){

            $filename=explode('/', $auto->kep_url)[1];
            Storage::disk('my_files')->delete('uploads/'.$filename);
            Storage::disk('my_files')->delete($filename);
            unlink(public_path( $auto->kep_url));

            //Storage::delete('uploads/',$filename);

           }
           $autos->delete();

            if (!empty($request->ids)) {
                DB::table('comment')
                    ->whereIn('auto_id', $request->ids)
                    ->delete();
            }
            if (!empty($request->ids)) {
                DB::table('views')
                    ->whereIn('auto_id', $request->ids)
                    ->delete();
            }


            return redirect()->back()->with('success', 'A kijelölt elemek törölve lettek.');
        }



        return redirect()->back()->with('error', 'Nem választottál ki egyetlen elemet sem... Cold sex');
    }

    public function show($id)
    {

        //$item = Auto::findOrFail($id);
        $car = DB::table('Auto')->where('id', $id)->first();
        $comments = DB::table('comment')
            ->leftJoin('users', 'comment.user_id', '=', 'users.id')  // A felhasználó neve
            ->where('comment.auto_id', $id)  // Csak az adott autó kommentjei
            ->select('comment.*', 'users.name as user_name')  // Kommentek és felhasználó neve
            ->get();


        $item = DB::table('Auto')
            ->join('users', 'Auto.user_id', '=', 'users.id')
            ->select('Auto.*', 'users.name as user_name')
            ->where('Auto.id', $id)
            ->first();

        if (!$item) {
            abort(404, 'Post not found');
        }

        $userId = Auth::id(); // Bejelentkezett felhasználó azonosítója

        $data = Auto::leftJoin('views', function ($join) use ($userId) {
            $join->on('Auto.id', '=', 'views.auto_id')
                 ->where('views.user_id', '=', $userId);
        })
        ->select('Auto.*', 'views.id as viewed', 'views.updated_at as date')
        ->get();

        $viewed = DB::table('views')
        ->where('user_id', $userId)
        ->where('auto_id', $id)
        ->exists();

        $count = DB::table('views')
        ->where('auto_id', $id)
        ->count();

        /*           DB::table('views')
            ->where('user_id', $userId)
            ->where('auto_id', $id)
            ->delete();*/

        return view('show', compact('item', 'comments', 'car', 'data', 'viewed', 'count'));
    }// view return
    public function like($id)
    {
        $userId = Auth::id();

        $viewExists = DB::table('views')
            ->where('user_id', $userId)
            ->where('auto_id', $id)
            ->exists();
        DB::table('views')
            ->where('user_id', $userId)
            ->where('auto_id', $id)
            ->update(['updated_at' => now()]);

        if($viewExists)
        {
            DB::table('views')
            ->where('user_id', $userId)
            ->where('auto_id', $id)
            ->delete();
        }
        else {
            // Új megtekintés rögzítése
            DB::table('views')->insert([
                'user_id' => $userId,
                'auto_id' => $id,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return redirect()->route('show', ['id' => $id])->with('viewed', $viewExists);
    }

    public function store(Request $request, $auto_id)
    {
        $validated = $request->validate([
            'comment' => 'required|string|max:1000',  // Komment hossza, érvényesítése
        ]);

        // Komment hozzáadása az adatbázishoz a DB osztály segítségével
        DB::table('comment')->insert([
            'auto_id' => $auto_id,  // Hozzárendeljük az autó/hirdetés id-jét
            'user_id' => Auth::id(),  // Bejelentkezett felhasználó ID-ja
            'comment' => $validated['comment'],  // A komment tartalma
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Átirányítás a hirdetés részletek oldalára, sikeres komment felvétel után
        return redirect()->route('show', $auto_id);

    }



}
