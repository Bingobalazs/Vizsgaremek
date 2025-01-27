<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Computer;
use Exception;
use Illuminate\Support\Facades\DB;

class ComputerController extends Controller
{
    public function showUploadForm()
    {
        return view('upload');
    }

    public function store(Request $request)
    {
        $data = explode("\n", trim($request->input('csv_data')));
        $header = str_getcsv(array_shift($data), ';');

        if ($header !== ['gyarto', 'tipus', 'ram', 'ssd', 'monitor']) {
            return back()->withErrors(['Hibás CSV fejlécek.']);
        }

        $errors = [];
        foreach ($data as $line) {
            $fields = str_getcsv($line, ';');
            if (count($fields) !== 5 || !is_numeric($fields[2]) || !is_numeric($fields[3]) || !in_array($fields[4], ['0', '1'])) {
                $errors[] = $line;
                continue;
            }

            if (!Computer::where([
                ['gyarto', '=', $fields[0]],
                ['tipus', '=', $fields[1]],
                ['ram', '=', $fields[2]],
                ['ssd', '=', $fields[3]],
                ['monitor', '=', $fields[4]],
            ])->exists()) {
                Computer::create([
                    'gyarto' => $fields[0],
                    'tipus' => $fields[1],
                    'ram' => (int) $fields[2],
                    'ssd' => (int) $fields[3],
                    'monitor' => (bool) $fields[4],
                ]);
            }
        }

        if (!empty($errors)) {
            return response()->json(['errors' => $errors], 422);
        }

        return redirect('/szamitogep/lista');
    }

    public function showList()
    {
        $computers = Computer::all();
        return view('list', compact('computers'));
    }

    public function delete($id)
    {
        Computer::destroy($id);
        return redirect('/szamitogep/lista');
    }
}